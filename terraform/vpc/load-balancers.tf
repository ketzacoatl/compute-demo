# Security Group for load-balancers
module "load-balancers-sg" {
  source      = "github.com/fpco/fpco-terraform-aws//tf-modules/security-group-base?ref=data-ops-eval"
  name        = "${var.name}-load-balancers"
  description = "security group for load balancer instances in the private subnet"
  vpc_id      = "${module.vpc.vpc_id}"
}

module "load-balancers-vpc-ssh-rule" {
  source            = "github.com/fpco/fpco-terraform-aws//tf-modules/ssh-sg?ref=data-ops-eval"
  cidr_blocks       = ["${var.vpc_cidr}"]
  security_group_id = "${module.load-balancers-sg.id}"
}

module "load-balancers-open-egress-rule" {
  source              = "github.com/fpco/fpco-terraform-aws//tf-modules/open-egress-sg?ref=data-ops-eval"
  security_group_id = "${module.load-balancers-sg.id}"
}

module "load-balancers-consul-agent-rules" {
  source            = "github.com/fpco/fpco-terraform-aws//tf-modules/consul-agent-sg?ref=data-ops-eval"
  cidr_blocks       = ["${var.vpc_cidr}"]
  security_group_id = "${module.load-balancers-sg.id}"
}

module "load-balancers-nomad-agent-rules" {
  source             = "github.com/fpco/fpco-terraform-aws//tf-modules/nomad-agent-sg?ref=data-ops-eval"
  cidr_blocks        = ["${var.vpc_cidr}"]
  security_group_id  = "${module.load-balancers-sg.id}"
}

module "load-balancers-public-http-rule" {
  source            = "github.com/fpco/fpco-terraform-aws//tf-modules/single-port-sg?ref=data-ops-eval"
  port              = "9999"
  description       = "Allow ingress to fabio (lb) port 9999 (TCP)"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${module.load-balancers-sg.id}"
}

module "load-balancers-admin-ui-rule" {
  source            = "github.com/fpco/fpco-terraform-aws//tf-modules/single-port-sg?ref=data-ops-eval"
  port              = "9998"
  description       = "Allow ingress to fabio admin port 9998 (TCP)"
  cidr_blocks       = ["${var.vpc_cidr}"]
  security_group_id = "${module.load-balancers-sg.id}"
}

#module "load-balancer-hostname" {
#  source          = "github.com/fpco/fpco-terraform-aws//tf-modules/init-snippet-hostname-simple?ref=data-ops-eval"
#  hostname_prefix = "${var.name}-load-balancer"
#}

data "template_file" "lb_user_data" {
  template = "${file("templates/fabio-lb-init.tpl")}"

  vars {
    init_prefix = ""
    log_prefix  = "OPS-LOG: "
    log_level   = "info"

    # for managing the hostname
    hostname_prefix = "fabio"

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
    nomad_node_class = "load-balancer"
    nomad_datacenter = "${var.name}.${var.region}"
    nomad_secret     = "${var.nomad_secret}"
    nomad_region     = "${var.region}"
  }
}

module "load-balancer-cluster" {
  source   = "github.com/fpco/fpco-terraform-aws//tf-modules/asg?ref=data-ops-eval"
  name     = "${var.name}"
  suffix   = "load-balancer-${var.region}"
  key_name = "${aws_key_pair.main.key_name}"
  ami      = "${var.ami}"

  #iam_profile     = "${aws_iam_instance_profile.load-balancer.name}"
  instance_type    = "${var.instance_type["load-balancer"]}"
  min_nodes        = "0"
  max_nodes        = "2"
  desired_capacity = "1"
  public_ip        = "false"
  subnet_ids       = ["${module.vpc.private_subnet_ids}"]
  # select availability zones based on private subnets in use
  azs = ["${slice(data.aws_availability_zones.available.names, 0, length(var.private_subnet_cidrs))}"]

  security_group_ids = ["${module.workers-sg.id}"]
  root_volume_size   = "10"
  user_data          = "${data.template_file.lb_user_data.rendered}"
}
