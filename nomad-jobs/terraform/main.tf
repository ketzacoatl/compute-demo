provider "nomad" {
  address = "${var.nomad_address}"
  region  = "${var.region}"
}

module "prometheus-exec" {
  source        = "github.com/ketzacoatl/terraform-cluster-common-nomad-jobs//prometheus-exec?ref=compute-demo"
  run           = "${var.prometheus["run"]}"
  region        = "${var.region}"
  datacenters   = "${var.datacenters}"
  consul_server = "${var.consul_server}"
  consul_token  = "${var.consul_token}"
}

module "fabio-manage" {
  source      = "github.com/ketzacoatl/terraform-cluster-common-nomad-jobs//fabio?ref=compute-demo"
  job_name    = "fabio-manage"
  run         = "${var.fabio_manage["run"]}"
  node_class  = "${var.fabio_manage["node_class"]}"
  region      = "${var.region}"
  datacenters = "${var.datacenters}"
}

module "fabio-compute" {
  source      = "github.com/ketzacoatl/terraform-cluster-common-nomad-jobs//fabio?ref=compute-demo"
  job_name    = "fabio-compute"
  run         = "${var.fabio_compute["run"]}"
  node_class  = "${var.fabio_compute["node_class"]}"
  region      = "${var.region}"
  datacenters = "${var.datacenters}"
}

module "grafana" {
  source      = "github.com/ketzacoatl/terraform-cluster-common-nomad-jobs//grafana?ref=compute-demo"
  run         = "${var.grafana["run"]}"
  region      = "${var.region}"
  datacenters = "${var.datacenters}"
  node_class  = "${var.grafana["node_class"]}"
}

module "hashi-ui" {
  source        = "github.com/ketzacoatl/terraform-cluster-common-nomad-jobs//hashi-ui?ref=compute-demo"
  run           = "${var.hashi-ui["run"]}"
  region        = "${var.region}"
  datacenters   = "${var.datacenters}"
  nomad_address = "${var.nomad_address}"
}

module "ladder" {
  source      = "github.com/ketzacoatl/terraform-cluster-common-nomad-jobs//ladder-docker?ref=compute-demo"
  run         = "${var.ladder["run"]}"
  region      = "${var.region}"
  datacenters = "${var.datacenters}"
}

module "node_exporter" {
  source      = "github.com/ketzacoatl/terraform-cluster-common-nomad-jobs//node_exporter?ref=compute-demo"
  run         = "${var.node_exporter["run"]}"
  region      = "${var.region}"
  datacenters = "${var.datacenters}"
  job_name    = "${var.node_exporter["job_name"]}"
}

module "nomad-metrics" {
  source      = "github.com/ketzacoatl/terraform-cluster-common-nomad-jobs//nomad-metrics?ref=compute-demo"
  run         = "${var.nomad-metrics["run"]}"
  region      = "${var.region}"
  datacenters = "${var.datacenters}"
  node_class  = "${var.nomad-metrics["node_class"]}"
}
