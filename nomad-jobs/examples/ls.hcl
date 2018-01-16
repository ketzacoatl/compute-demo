job "ls" {
  region      = "us-west-2"
  datacenters = ["data-ops-eval.us-west-2"]
  type        = "batch"

  group "ls" {
    count  = 1

    task "ls" {
      driver = "exec"

      artifact {
        source      = "https://github.com/themotion/ladder/releases/download/v0.1.1rc1/ladder-v0.1.1rc1.linux-amd64.bin"
        destination = "local/ladder"

        options {
          checksum = "sha512:616d0bc101d57b7e711cd89e5305c4ecd9c25aa54a91653bdc17b6d4b5279e65487a20a08338a350f5f489507f78706312fafa5d89096e58e3968198d77867bf"
        }
      }
 
      config {
        command = "/bin/ls"

        args = [ "-Alh", "local" ]
      }

      resources {
        cpu    = 20
        memory = 32
      }
    }
  }
}
