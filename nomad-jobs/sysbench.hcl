job "sysbench" {
  region      = "us-west-2"
  datacenters = ["data-ops-eval.us-west-2"]
  type        = "batch"

  group "sysbench" {
    count  = 2

    task "sysbench" {
      driver = "docker"
      config {
        image   = "tjakobsson/sysbench:1.0"
        command = "sysbench"
        args    = ["--test=cpu", "--cpu-max-prime=20000000", "run"]
      }

      resources {
        cpu    = 740
        memory = 400
        network {
          mbits = 1
        }
      }
    }
  }
}
