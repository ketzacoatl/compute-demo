job "loadbalancer" {
  region      = "us-west-2"
  datacenters = ["data-ops-eval.us-west-2"]
  type        = "service"

  group "fabio" {
    count  = 1

    task "server" {
      driver = "exec"

      artifact {
        source      = "https://github.com/fabiolb/fabio/releases/download/v1.5.3/fabio-1.5.3-go1.9.2-linux_amd64"
        destination = "local/"

        options {
          checksum = "sha512:acebab491a5f5e8d25d673a9a4a4ca2f178281a6a46895359dcbd8ef53499640d46bb253f07fc8876240171d70526f7ed0f3d267b623a9f003c50e9d4fd0214c"
        }
      }

      config {
        command = "local/fabio-1.5.3-go1.9.2-linux_amd64"

        args = [
#         "-cfg", "local/fabio.properties"
        ]
      }

      constraint {
        attribute = "${node.class}"
        operator  = "="
        value     = "loadbalancer"
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
            static = 9999
          }
        }
      }

      template {
        data = <<EOH
# registry.consul.addr = localhost:8500
        EOH

        destination = "local/fabio.properties"
      }
    }
  }
}
