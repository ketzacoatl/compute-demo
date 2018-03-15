job "${job_name}" {
  region      = "${region}"
  datacenters = ["${datacenters}"]
  type        = "service"

  group "tls-example" {
    task "nginx" {
      driver = "docker"

      config {
        image = "nginx"
      }

      resources {
        cpu    = ${cpu_limit}
        memory = ${mem_limit}
        network {
          mbits = ${net_limit}

          port "http" {
            static = 80
          }
        }
      }

      service {
        name = "nginx-${job_name}"
        tags = [
          "${fabio_prefix}-${domain}/" 
        ]

        port = "http"
      }
    }
  }
}
