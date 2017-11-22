#module "worker-hostname" {
#  source          = "github.com/fpco/fpco-terraform-aws//tf-modules/init-snippet-hostname-simple?ref=data-ops-eval"
#  hostname_prefix = "${var.name}-worker"
#}

data "template_file" "worker_user_data" {
  template = "${file("templates/worker-init.tpl")}"

  vars {
#   init_prefix = "${module.worker-hostname.init_snippet}"
    init_prefix = ""
    log_prefix  = "OPS-LOG: "
    log_level   = "info"

    # for managing the hostname
    hostname_prefix = "workers"

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
    nomad_node_class = "compute"
    nomad_datacenter = "${var.name}.${var.region}"
    nomad_secret     = "${var.nomad_secret}"
    nomad_region     = "${var.region}"
  }
}

module "workers" {
  source   = "github.com/fpco/fpco-terraform-aws//tf-modules/asg?ref=data-ops-eval"
  name     = "${var.name}"
  suffix   = "workers-${var.region}"
  key_name = "${aws_key_pair.main.key_name}"
  ami      = "${var.ami}"

  ##iam_profile = ""
  instance_type    = "${var.instance_type["worker"]}"
  min_nodes        = "0"
  max_nodes        = "10"
  desired_capacity = "1"
  public_ip        = "false"
  subnet_ids       = ["${module.vpc.private_subnet_ids}"]
  # select availability zones based on private subnets in use
  azs = ["${slice(data.aws_availability_zones.available.names, 0, length(var.private_subnet_cidrs))}"]

  security_group_ids = [
    "${module.private-ssh-sg.id}",
    "${module.open-egress-sg.id}",
    "${module.consul-agent-sg.id}",
    "${module.nomad-agent-sg.id}",
  ]

  root_volume_size = "30"
  user_data        = "${data.template_file.worker_user_data.rendered}"
}
