job "sleep" {
  region      = "us-west-2"
  datacenters = ["data-ops-eval.us-west-2"]
  type        = "batch"

  group "sleep" {
    count  = 1

    task "sleep" {
      driver = "exec"

      config {
        command = "/bin/sleep"

        args = [ "1" ]
      }

      resources {
        cpu    = 20
        memory = 32
      }
    }
  }
}
