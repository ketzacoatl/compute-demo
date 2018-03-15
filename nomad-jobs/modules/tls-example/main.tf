data "template_file" "tls-example" {
  count    = "${var.run}"
  template = "${file("${path.module}/templates/application.hcl")}"

  vars {
    job_name     = "${var.job_name}"
    region       = "${var.region}"
    datacenters  = "${join(",",var.datacenters)}"
    node_class   = "${var.node_class}"
    cpu_limit    = "${var.cpu_limit}"
    mem_limit    = "${var.mem_limit}"
    net_limit    = "${var.net_limit}"
    fabio_prefix = "${var.fabio_prefix}"
    domain       = "${var.domain}"
  }
}

resource "nomad_job" "tls-example" {
  jobspec = "${data.template_file.tls-example.rendered}"
}
