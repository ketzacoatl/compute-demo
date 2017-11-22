job "grafana" {
  region      = "us-west-2"
  datacenters = ["data-ops-eval.us-west-2"]
  type        = "service"

  group "ui" {
    count  = 1

    task "ui" {
      driver = "docker"
      config {
        image   = "grafana/grafana"
#       command = "sysbench"
#       args    = ["--test=cpu", "--cpu-max-prime=20000000", "run"]
      }

      constraint {
        attribute = "${node.class}"
        operator  = "="
        value     = "manage"
      }

      resources {
        cpu    = 500
        memory = 256
        network {
          mbits = 5
          port "http" {
            static = 3000
          }
        }
      }

      service {
        port = "http"

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

