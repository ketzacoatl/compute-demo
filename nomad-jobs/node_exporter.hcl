job "node-metrics" {
  region      = "us-west-2"
  datacenters = ["data-ops-eval.us-west-2"]
  type        = "system"

  group "node_exporter" {

    task "node_exporter" {
      driver = "raw_exec"

      artifact {
        source      = "https://github.com/prometheus/node_exporter/releases/download/v0.15.1/node_exporter-0.15.1.linux-amd64.tar.gz"
        destination = "local/"

        options {
          checksum = "sha512:d4e52db9577a795231ce1901d3a11fefb9152848bff2283ba04b8d196461a1ddc55ec07d6a3a939b7775c7ecbb06dff4c3ff89c2cd97b89c696bef49d59f8b5a"
        }
      }

      config {
        command = "node_exporter-0.15.1.linux-amd64/node_exporter"
        args    = []
      }

      service {
        name = "node-exporter"
        port = "metrics"

        check {
          type     = "http"
          path     = "/"
          interval = "30s"
          timeout  = "5s"
        }
      }

      resources {
        cpu    = 200
        memory = 128
        network {
          mbits = 3

          port "metrics" {
            static = 9100
          }
        }
      }
    }
  }
}
