resource "consul_keys" "fabio-manage" {
  datacenter = "${var.datacenters}"
  token      = "${var.consul_token}"

  key {
    path  = "${var.fabio_manage_cert["path"]}"
    value = "${var.fabio_manage_cert["value"]}"
  }

  key {
    path  = "${var.fabio_manage_ca["path"]}"
    value = "${var.fabio_manage_ca["value"]}"
  }
}

resource "consul_keys" "fabio-compute" {
  datacenter = "${var.datacenters}"
  token      = "${var.consul_token}"

  key {
    path  = "${var.fabio_compute_cert["path"]}"
    value = "${var.fabio_compute_cert["value"]}"
  }

  key {
    path  = "${var.fabio_compute_ca["path"]}"
    value = "${var.fabio_compute_ca["value"]}"
  }
}
