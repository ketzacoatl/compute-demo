variable "region" {
  description = "nomad region"
  type        = "string"
}

variable "run_prometheus" {
  description = "boolean, to run or not to run"
  default = "true"
}

variable "prometheus_version" {
  description = "version of prometheus to download, verify, and run"
  default = "1.8.2"
}

variable "prometheus_version" {
  description = "version of prometheus to download, verify, and run"
  default = "sha512:f7577d48dcf5a8945b39c67edc59bf09c8420df6860206d06ef8fb43907a298ecc8f4a01bbbadc600b42bb2a8ac44622d30cfdc18e255d977c59515baf97b284"
}

variable "prometheus_cpu_limit" {
  description = "CPU resource limit"
  default = "450"
}

variable "prometheus_mem_limit" {
  description = "Memory resource limit"
  default = "512"
}

variable "prometheus_net_limit" {
  description = "Network resource limit"
  default = "5"
}

# create a list of template_file data sources with init for each instance
data "template_file" "prometheus" {
  count    = "${var.run_prometheus}"
  template = "${file("../job-templates/prometheus-exec.tpl")}"
  vars {
    region      = "${var.region}"
    datacenters = ["${var.datacenters}"]
    version     = "${var.prometheus_version}"
    checksum    = "${var.prometheus_checksum}"
    cpu_limit   = "${var.prometheus_cpu_limit}"
    mem_limit   = "${var.prometheus_mem_limit}"
    net_limit   = "${var.prometheus_net_limit}"
  }
}

provider "nomad" {
  address = "nomad-server.service.consul"
  region  = "${var.region}"
}

resource "nomad_job" "prometheus" {
  jobspec = "${data.template_file.prometheus.rendered}"
}
