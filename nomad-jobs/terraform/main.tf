provider "nomad" {
  address = "nomad-server.service.consul"
  region  = "${var.region}"
}

module "prometheus-exec" {
  source        = "github.com/ketzacoatl/terraform-cluster-common-nomad-jobs//prometheus-exec?ref=0.1"
  run           = "${var.prometheus["run"]}"
  region        = "${var.region}"
  datacenters   = "${var.datacenters}"
  consul_server = "${var.consul_server}"
  consul_token  = "${var.consul_token}"
}

module "fabio-manage" {
  source      = "github.com/ketzacoatl/terraform-cluster-common-nomad-jobs//fabio?ref=0.1"
  job_name    = "fabio-manage"
  run         = "${var.fabio_manage["run"]}"
  node_class  = "${var.fabio_manage["node_class"]}"
  region      = "${var.region}"
  datacenters = "${var.datacenters}"
}

module "fabio-compute" {
  source      = "github.com/ketzacoatl/terraform-cluster-common-nomad-jobs//fabio?ref=0.1"
  job_name    = "fabio-manage"
  run         = "${var.fabio_compute["run"]}"
  node_class  = "${var.fabio_compute["node_class"]}"
  region      = "${var.region}"
  datacenters = "${var.datacenters}"
}

module "fabio-default" {
  source      = "github.com/ketzacoatl/terraform-cluster-common-nomad-jobs//fabio?ref=0.1"
  job_name    = "fabio-default"
  run         = "${var.fabio_default["run"]}"
  node_class  = "${var.fabio_default["node_class"]}"
  region      = "${var.region}"
  datacenters = "${var.datacenters}"
}

module "grafana" {
  source      = "github.com/ketzacoatl/terraform-cluster-common-nomad-jobs//grafana?ref=0.1"
  run         = "${var.grafana["run"]}"
  region      = "${var.region}"
  datacenters = "${var.datacenters}"
  node_class  = "${var.grafana["node_class"]}"
}

module "hashi-ui" {
  source      = "github.com/ketzacoatl/terraform-cluster-common-nomad-jobs//hashi-ui?ref=0.1"
  run         = "${var.hashi-ui["run"]}"
  region      = "${var.region}"
  datacenters = "${var.datacenters}"
}

module "ladder" {
  source      = "github.com/ketzacoatl/terraform-cluster-common-nomad-jobs//ladder-docker?ref=0.1"
  run         = "${var.ladder["run"]}"
  region      = "${var.region}"
  datacenters = "${var.datacenters}"
}

module "node_exporter" {
  source      = "github.com/ketzacoatl/terraform-cluster-common-nomad-jobs//node_exporter?ref=0.1"
  run         = "${var.node_exporter["run"]}"
  region      = "${var.region}"
  datacenters = "${var.datacenters}"
  job_name    = "${var.node_exporter["job_name"]}"
}

module "nomad-metrics" {
  source      = "github.com/ketzacoatl/terraform-cluster-common-nomad-jobs//nomad-metrics?ref=0.1"
  run         = "${var.nomad-metrics["run"]}"
  region      = "${var.region}"
  datacenters = "${var.datacenters}"
  node_class  = "${var.nomad-metrics["node_class"]}"
}

module "sysbench" {
  source      = "github.com/ketzacoatl/terraform-cluster-common-nomad-jobs//sysbench?ref=0.1"
  run         = "${var.sysbench["run"]}"
  region      = "${var.region}"
  datacenters = "${var.datacenters}"
}
