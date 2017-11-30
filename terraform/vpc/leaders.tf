# Security Group for consul/nomad leaders
module "core-leaders-sg" {
  source      = "github.com/fpco/fpco-terraform-aws//tf-modules/security-group-base?ref=data-ops-eval"
  name        = "${var.name}-core-leaders"
  description = "security group for core-leader instances in the private subnet"
  vpc_id      = "${module.vpc.vpc_id}"
}

module "core-leaders-vpc-ssh-rule" {
  source            = "github.com/fpco/fpco-terraform-aws//tf-modules/ssh-sg?ref=data-ops-eval"
  cidr_blocks       = ["${var.vpc_cidr}"]
  security_group_id = "${module.core-leaders-sg.id}"
}

module "core-leaders-open-egress-rule" {
  source              = "github.com/fpco/fpco-terraform-aws//tf-modules/open-egress-sg?ref=data-ops-eval"
  security_group_id = "${module.core-leaders-sg.id}"
}

module "core-leaders-consul-leader-rules" {
  source            = "github.com/fpco/fpco-terraform-aws//tf-modules/consul-leader-sg?ref=data-ops-eval"
  cidr_blocks       = ["${var.private_subnet_cidrs}"]
  security_group_id = "${module.core-leaders-sg.id}"
}

module "core-leaders-consul-agent-rules" {
  source            = "github.com/fpco/fpco-terraform-aws//tf-modules/consul-agent-sg?ref=data-ops-eval"
  cidr_blocks       = ["${var.vpc_cidr}"]
  security_group_id = "${module.core-leaders-sg.id}"
}

module "core-leaders-nomad-leader-rules" {
  source             = "github.com/fpco/fpco-terraform-aws//tf-modules/nomad-server-sg?ref=data-ops-eval"
  # subnets where nomad servers are deployed
  server_cidr_blocks = ["${var.private_subnet_cidrs}"]
  # subnets where nomad workers/agents are deployed
  worker_cidr_blocks = ["${var.vpc_cidr}"]
  security_group_id  = "${module.core-leaders-sg.id}"
}

module "core-leaders-nomad-agent-rules" {
  source             = "github.com/fpco/fpco-terraform-aws//tf-modules/nomad-agent-sg?ref=data-ops-eval"
  cidr_blocks        = ["${var.vpc_cidr}"]
  security_group_id  = "${module.core-leaders-sg.id}"
}

# IAM role to attach the instance's policy
resource "aws_iam_role" "core-leader-role" {
  count = "${length(var.private_subnet_cidrs)}"
  name  = "${var.name}-core-leader-role-${format("%02d", count.index)}"

  assume_role_policy = <<END_POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
END_POLICY
}

# IAM policy for the core leaders instances on EC2
resource "aws_iam_instance_profile" "core-leader-iam-profile" {
  count = "${length(var.private_subnet_cidrs)}"
  name  = "${var.name}-core-leader-profile-${format("%02d", count.index)}"
  role  = "${element(aws_iam_role.core-leader-role.*.name, count.index)}"
}

# PUT THIS INTO A MODULE - XXX
# IAM policy to support consul/nomad EC2 discovery plugins
resource "aws_iam_policy" "ec2-discovery-policy" {
  name = "${var.name}-ec2-discovery-policy"
  policy = <<END_POLICY
{
  "Statement": [
    {
      "Action": ["ec2:DescribeInstances"],
      "Effect": "Allow",
      "Resource": ["*"]
    }
  ],
  "Version": "2012-10-17"
}
END_POLICY
}

# Attach the auto-discovery IAM policy to our role and it's instance profile
# one policy is attached to N roles (based on the number of instances/subnets)
resource "aws_iam_role_policy_attachment" "core-leader-attach-ec2-discovery" {
  count      = "${length(var.private_subnet_cidrs)}"
  role       = "${element(aws_iam_role.core-leader-role.*.name, count.index)}"
  policy_arn = "${aws_iam_policy.ec2-discovery-policy.arn}"
}

# IAM policy to grant access to KMS key used to encrypt core-leader data volumes
#data "aws_iam_policy_document" "core-leaders-access-kms-key" {
#  statement {
#    sid = "Allow use of the key, to encrypt core-leader data volumes"
#    actions = [
#      "",
#    ]
#    resources = [
#      "",
#    ]
#  }
#}

# crypto key in AWS KMS for encrypting EBS data volumes
#resource "aws_kms_key" "core-leaders" {
#  description             = "KMS key to encrypt leader data volumes"
#  deletion_window_in_days = 7
#  policy                  = ""
#}

# EBS volumes for the leaders
module "leader-data" {
  source       = "github.com/fpco/fpco-terraform-aws//tf-modules/persistent-ebs-volumes?ref=data-ops-eval"
  name_prefix  = "${var.name}-leader-data"
  azs          = ["${slice(data.aws_availability_zones.available.names, 0, length(var.private_subnet_cidrs))}"]
  # create one EBS volume per subnet
  #volume_count = "${length(module.private-subnets.ids)}"
  volume_count = "${length(module.vpc.private_subnet_ids)}"
  size         = "10"
  #encrypted    = "true"
  # this param maps to aws_ebs_volume.kms_key_id, but that is actually the ARN..
  #kms_key_id   = "${aws_kms_key.core-leaders.arn}"
  snapshot_ids = [""]
}

# Attach IAM policies to roles (for EC2 instances and their EBS data volumes)
# N policies are attached to N roles (based on the number of instances/subnets)
resource "aws_iam_role_policy_attachment" "core-leader-attach-ebs-volume" {
  count      = "${length(var.private_subnet_cidrs)}"
  role       = "${element(aws_iam_role.core-leader-role.*.name, count.index)}"
  policy_arn = "${element(module.leader-data.iam_volume_policy_arns, count.index)}"
}

module "core-leader-hostname" {
  source          = "github.com/fpco/fpco-terraform-aws//tf-modules/init-snippet-hostname-simple?ref=data-ops-eval"
  hostname_prefix = "${var.name}-core-leader"
}

# create a list of template_file data sources with init for each instance
data "template_file" "core-leader-init" {
  count    = "${length(var.private_subnet_cidrs)}"
  template = "${file("templates/core-leader-init.tpl")}"
  vars {
    init_prefix   = "${module.core-leader-hostname.init_snippet}"
    attach_volume = "${module.leader-data.volume_mount_snippets[count.index]}"
    log_prefix    = "OPS-LOG: "
    log_level     = "info"

    # for managing the hostname
    hostname_prefix = "core-leaders"
    # the number of core-leaders (maps 1:1 with private subnets)
    leader_count    = "${length(var.private_subnet_cidrs)}"

    # file path to bootstrap.sls pillar file
    bootstrap_pillar_file      = "/srv/pillar/bootstrap.sls"
    # consul formula config params
    consul_disable_remote_exec = "true"
    consul_datacenter          = "${var.name}-${var.region}"
    consul_secret_key          = "${var.consul_secret_key}"

    # these tokens should live elsewhere, like in credstash
    consul_master_token = "${var.consul_master_token}"
    consul_client_token = "${var.consul_master_token}"

    # nomad formula config params
    nomad_datacenter   = "${var.name}.${var.region}"
    nomad_secret       = "${var.nomad_secret}"
    nomad_region       = "${var.region}"
    nomad_server_count = "${length(var.private_subnet_cidrs)}"
  }
}

# calculate (render) string-list of Private IP addresses
data "template_file" "core_leaders_private_ips" {
  count    = "${length(var.private_subnet_cidrs)}"
  template = "$${ip}"
  vars {
    ip = "${cidrhost(var.private_subnet_cidrs[count.index], 4)}"
  }
}

# create an auto-recoverable EC2 instance running as a hashistack "core" leader
module "core-leaders" {
  source = "github.com/fpco/fpco-terraform-aws//tf-modules/ec2-fixed-ip-auto-recover-instances?ref=data-ops-eval"
  # name scheme looks like "name-core-leader-01" and so on
  name_prefix        = "${var.name}"
  name_format        = "%s-core-leader-%02d"
  ami                = "${var.ami}"
  instance_type      = "${var.instance_type["core-leader"]}"
  iam_profiles       = ["${aws_iam_instance_profile.core-leader-iam-profile.*.name}"]
  #subnet_ids        = ["${module.private-subnets.ids}"]
  subnet_ids         = ["${module.vpc.private_subnet_ids}"]
  private_ips        = ["${data.template_file.core_leaders_private_ips.*.rendered}"]
  key_name           = "${aws_key_pair.main.key_name}"
  root_volume_size   = "10"
  security_group_ids = ["${module.core-leaders-sg.id}"]
  user_data          = ["${data.template_file.core-leader-init.*.rendered}"]
}
