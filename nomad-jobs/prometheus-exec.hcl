job "prometheus" {
  region      = "us-west-2"
  datacenters = ["data-ops-eval.us-west-2"]
  type        = "service"

  group "prom" {
    count  = 1

    task "server" {
      driver = "exec"

      artifact {
        source      = "https://github.com/prometheus/prometheus/releases/download/v1.8.2/prometheus-1.8.2.linux-amd64.tar.gz"
        destination = "local/"

        options {
          checksum = "sha512:f7577d48dcf5a8945b39c67edc59bf09c8420df6860206d06ef8fb43907a298ecc8f4a01bbbadc600b42bb2a8ac44622d30cfdc18e255d977c59515baf97b284"
        }
      }

      config {
        command = "prometheus-1.8.2.linux-amd64/prometheus"

        args = [
          "-config.file=local/config.yaml"
        ]
      }

      constraint {
        attribute = "${node.class}"
        operator  = "="
        value     = "manage"
      }

#     env {
#       AWS_SECRET_ACCESS_KEY = ""
#       AWS_ACCESS_KEY_ID     = ""
#     }

      service {
        port = "http"

        check {
          type     = "http"
          path     = "/"
          interval = "30s"
          timeout  = "5s"
        }
      }

      resources {
        cpu    = 500
        memory = 256
        network {
          mbits = 3

          port "http" {
            static = 9090
          }
        }
      }

      template {
        data = <<EOH
        EOH

        destination = "local/config.yaml"
      }
    }
  }
}
