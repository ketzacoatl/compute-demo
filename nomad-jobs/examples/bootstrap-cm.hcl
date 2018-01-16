job "cm-bootstrap" {
  region      = "us-east-2"
  datacenters = ["poc-demo.us-east-2"]
  type        = "system"

  group "cm-bootstrap" {
    count  = 1

    task "bootstrap-salt-formula" {
      driver = "raw_exec"

      config {
        command = "/usr/bin/salt-call"

        args = [
          "--local",
          "--file-root", "/srv/bootstrap-salt-formula/formula",
          "--pillar-root", "/srv/bootstrap-salt-formula/pillar",
          "--config-dir", "/srv/bootstrap-salt-formula/conf",
          "state.highstate"
        ]
      }

      resources {
        cpu    = 400
        memory = 512
      }
    }
  }
}
