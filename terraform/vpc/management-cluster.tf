# Security Group for management manage
module "manage-sg" {
  source      = "github.com/fpco/fpco-terraform-aws//tf-modules/security-group-base?ref=data-ops-eval"
  name        = "${var.name}-manage"
  description = "security group for management worker instances in the private subnet"
  vpc_id      = "${module.vpc.vpc_id}"
}

module "manage-vpc-ssh-rule" {
  source            = "github.com/fpco/fpco-terraform-aws//tf-modules/ssh-sg?ref=data-ops-eval"
  cidr_blocks       = ["${var.vpc_cidr}"]
  security_group_id = "${module.manage-sg.id}"
}

module "manage-open-egress-rule" {
  source              = "github.com/fpco/fpco-terraform-aws//tf-modules/open-egress-sg?ref=data-ops-eval"
  security_group_id = "${module.manage-sg.id}"
}

module "manage-consul-agent-rules" {
  source            = "github.com/fpco/fpco-terraform-aws//tf-modules/consul-agent-sg?ref=data-ops-eval"
  cidr_blocks       = ["${var.vpc_cidr}"]
  security_group_id = "${module.manage-sg.id}"
}

module "manage-nomad-agent-rules" {
  source             = "github.com/fpco/fpco-terraform-aws//tf-modules/nomad-agent-sg?ref=data-ops-eval"
  cidr_blocks        = ["${var.vpc_cidr}"]
  security_group_id  = "${module.manage-sg.id}"
}



#module "manage-hostname" {
#  source          = "github.com/fpco/fpco-terraform-aws//tf-modules/init-snippet-hostname-simple?ref=data-ops-eval"
#  hostname_prefix = "${var.name}-manage"
#}

data "template_file" "manage_user_data" {
  template = "${file("templates/manage-init.tpl")}"

  vars {
#   init_prefix = "${module.manage-hostname.init_snippet}"
    init_prefix = ""
    log_prefix  = "OPS-LOG: "
    log_level   = "info"

    # for managing the hostname
    hostname_prefix = "manage"

    # file path to bootstrap.sls pillar file
    bootstrap_pillar_file = "/srv/pillar/bootstrap.sls"

    # consul formula config params
    consul_disable_remote_exec = "true"
    consul_datacenter          = "${var.name}-${var.region}"
    consul_secret_key          = "${var.consul_secret_key}"
    consul_leader_ip           = "${data.template_file.core_leaders_private_ips.0.rendered}"

    # these tokens should live elsewhere, like in credstash
    consul_client_token = "${var.consul_master_token}"

    # nomad formula config params
    nomad_node_class = "manage"
    nomad_datacenter = "${var.name}.${var.region}"
    nomad_secret     = "${var.nomad_secret}"
    nomad_region     = "${var.region}"
  }
}

# IAM role to attach the instance's policy
resource "aws_iam_role" "manage_role" {
  name  = "${var.name}-manage-role"

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

resource "aws_iam_instance_profile" "manage" {
  name  = "${var.name}-manage-profile"
  role  = "${aws_iam_role.manage_role.name}"
}

# Attach the auto-discovery IAM policy to our role and it's instance profile
# one policy is attached to N roles (based on the number of instances/subnets)
resource "aws_iam_role_policy_attachment" "manage_autoscaler" {
  role       = "${aws_iam_role.manage_role.name}"
  policy_arn = "${aws_iam_policy.autoscaler.arn}"
}

module "manage-cluster" {
  source   = "github.com/fpco/fpco-terraform-aws//tf-modules/asg?ref=data-ops-eval"
  name     = "${var.name}"
  suffix   = "manage-${var.region}"
  key_name = "${aws_key_pair.main.key_name}"
  ami      = "${var.ami}"

  iam_profile      = "${aws_iam_instance_profile.manage.name}"
  instance_type    = "${var.instance_type["manage"]}"
  min_nodes        = "0"
  max_nodes        = "2"
  desired_capacity = "1"
  public_ip        = "false"
  subnet_ids       = ["${module.vpc.private_subnet_ids}"]
  # select availability zones based on private subnets in use
  azs = ["${slice(data.aws_availability_zones.available.names, 0, length(var.private_subnet_cidrs))}"]

  security_group_ids = ["${module.manage-sg.id}"]
  root_volume_size   = "30"
  user_data          = "${data.template_file.manage_user_data.rendered}"
}
