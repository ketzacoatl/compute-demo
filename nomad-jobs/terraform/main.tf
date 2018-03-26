provider "nomad" {
  version = "~> 1.1"

  address = "${var.nomad_address}"
  region  = "${var.region}"
}

provider "template" {
  version = "~> 1.0"
}

module "prometheus-exec" {
  source = "github.com/kerscher/terraform-cluster-common-nomad-jobs//prometheus-exec?ref=compute-demo-develop"

  run           = "${var.prometheus["run"]}"
  region        = "${var.region}"
  datacenters   = "${var.datacenters}"
  node_class    = "${var.prometheus["node_class"]}"
  consul_server = "${var.consul_server}"
  consul_token  = "${var.consul_token}"
}

data "template_file" "fabio-manage-configuration" {
  vars {
    clientca = "${null_resource.vars_fabio_manage.triggers.ca_path}"
    cert     = "${null_resource.vars_fabio_manage.triggers.cert_path}"
    token    = "${var.fabio_manage_token}"
  }

  template = "${file("./templates/fabio-manage.conf")}"
}

module "fabio-manage" {
  source = "github.com/kerscher/terraform-cluster-common-nomad-jobs//fabio?ref=compute-demo-develop"

  job_name      = "fabio-manage"
  run           = "${null_resource.vars.fabio_manage.triggers.run}"
  node_class    = "${null_resource.vars.fabio_manage.triggers.node_class}"
  region        = "${var.region}"
  datacenters   = "${var.datacenters}"
  configuration = "${data.template_file.fabio-manage-configuration.rendered}"
}

data "template_file" "fabio-compute-configuration" {
  vars {
    clientca = "${var.fabio_compute_ca["path"]}"
    cert     = "${var.fabio_compute_cert["path"]}"
    token    = "${var.fabio_compute_token}"
  }

  template = "${file("./templates/fabio-compute.conf")}"
}

module "fabio-compute" {
  source        = "github.com/kerscher/terraform-cluster-common-nomad-jobs//fabio?ref=compute-demo-develop"
  job_name      = "fabio-compute"
  run           = "${null_resource.vars.fabio_compute.triggers.run}"
  node_class    = "${null_resource.vars.fabio_compute.triggers.node_class}"
  region        = "${var.region}"
  datacenters   = "${var.datacenters}"
  configuration = "${data.template_file.fabio-compute-configuration.rendered}"
}

module "grafana" {
  source      = "github.com/kerscher/terraform-cluster-common-nomad-jobs//grafana?ref=compute-demo-develop"
  run         = "${var.grafana["run"]}"
  region      = "${var.region}"
  datacenters = "${var.datacenters}"
  node_class  = "${var.grafana["node_class"]}"
}

module "hashi-ui" {
  source = "github.com/kerscher/terraform-cluster-common-nomad-jobs//hashi-ui?ref=compute-demo-develop"

  run           = "${var.hashi-ui["run"]}"
  region        = "${var.region}"
  datacenters   = "${var.datacenters}"
  nomad_address = "${var.nomad_address}"
  node_class    = "${var.hashi-ui["node_class"]}"
}

module "node_exporter" {
  source = "github.com/kerscher/terraform-cluster-common-nomad-jobs//node_exporter?ref=compute-demo-develop"

  run         = "${var.node_exporter["run"]}"
  region      = "${var.region}"
  datacenters = "${var.datacenters}"
  job_name    = "${var.node_exporter["job_name"]}"
}

module "nomad-metrics" {
  source = "github.com/kerscher/terraform-cluster-common-nomad-jobs//nomad-metrics?ref=compute-demo-develop"

  run         = "${var.nomad-metrics["run"]}"
  region      = "${var.region}"
  datacenters = "${var.datacenters}"
  node_class  = "${var.nomad-metrics["node_class"]}"
}

module "tls-example" {
  source = "../modules/tls-example"

  run          = "${var.tls-example["run"]}"
  region       = "${var.region}"
  datacenters  = "${var.datacenters}"
  node_class   = "${var.tls-example["node_class"]}"
  fabio_prefix = "${var.tls-example["fabio_prefix"]}"
  domain       = "${var.tls-example["domain"]}"
}
