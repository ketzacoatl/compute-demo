variable "consul_server" {
  description = "Address of Consul server"
}

variable "consul_token" {
  description = "Token to access Consul"
}

variable "region" {
  description = "nomad region"
  type        = "string"
}

variable "datacenters" {
  description = "nomad datacenters"
  type        = "list"
}

# Prometheus
variable "prometheus" {
  description = "parameters for prometheus module"
  type        = "map"

  default = {
    run = true
  }
}

# Fabio
# Unfortunately due to how Terraform handles nested maps, this is needed
variable "fabio_manage" {
  description = "parameters for fabio-manage module"
  type        = "map"

  default = {
    run        = true
    node_class = "manage"
  }
}

variable "fabio_compute" {
  description = "parameters for fabio-compute module"
  type        = "map"

  default = {
    run        = true
    node_class = "compute"
  }
}

variable "fabio_default" {
  description = "parameters for fabio-default module"
  type        = "map"

  default = {
    run        = true
    node_class = "default"
  }
}

variable "grafana" {
  description = "parameters for grafana module"
  type        = "map"

  default = {
    run        = true
    node_class = "manage"
  }
}

variable "hashi-ui" {
  description = "parameters for hashi-ui module"
  type        = "map"

  default = {
    run = true
  }
}

variable "ladder" {
  description = "parameters for ladder module"
  type        = "map"

  default = {
    run = true
  }
}

variable "node_exporter" {
  description = "parameters for node_exporter module"
  type        = "map"

  default = {
    run      = true
    job_name = "node_exporter"
  }
}

variable "nomad-metrics" {
  description = "parameters for nomad-metrics module"
  type        = "map"

  default = {
    run        = true
    node_class = "manage"
  }
}

variable "sysbench" {
  description = "parameters for sysbench module"
  type        = "map"

  default = {
    run = true
  }
}
