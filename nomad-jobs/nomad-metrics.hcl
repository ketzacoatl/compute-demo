job "nomad-metrics" {
  region      = "us-west-2"
  datacenters = ["data-ops-eval.us-west-2"]
  type        = "service"

  group "nomad-exporter" {
    count  = 1

    task "nomad-exporter" {
      driver = "docker"
      config {
        image   = "nomon/nomad-exporter"
      }

      constraint {
        attribute = "${node.class}"
        operator  = "="
        value     = "manage"
      }

      resources {
        cpu    = 250
        memory = 160
        network {
          mbits = 3
          port "metrics" {
            static = 9172
          }
        }
      }

      service {
        name = "nomad-exporter"
        port = "metrics"

        check {
          type     = "http"
          path     = "/"
          interval = "30s"
          timeout  = "5s"
        }
      }
    }
  }
}

