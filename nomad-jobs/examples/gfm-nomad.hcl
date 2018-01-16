job "gfm-nomad" {
  region      = "us-west-2"
  datacenters = ["data-ops-eval.us-west-2"]
  type        = "service"

  group "gfm-nomad" {
    count  = 1

    task "gfm" {
      driver = "exec"

      artifact {
        source      = "https://download.fpcomplete.com/ops/ops-v0.3.0-linux-amd64"
        destination = "local/"

        options {
          checksum = "sha512:7cdaedafd05ebd7199b3e7fb969408ea5d3a994a41f8468fe1c4cbbe314ef8cb745e0cc8be622ff144c9c2dc5bfcae4605f74f5cb871bb46f74b39d6b40f52e9"
        }
      }

      artifact {
        source      = "https://releases.hashicorp.com/terraform/0.10.8/terraform_0.10.8_linux_amd64.zip"
        destination = "local/"

        options {
          checksum = "sha512:7435014a4b8c69d6ab07e88c88d9cb51dfcb3fb08548fd557671d8fbe5701faf61b22d167bbd4852ffbb02d53cad2c0e26c746f5b17ef7f860f568b6652c8388"
        }
      }

      config {
        command = "local/ops-v0.3.0-linux-amd64"

        args = [
          "git",
          "file-monitor",
          "local/nomad-jobs.yaml"
        ]
      }

      constraint {
        attribute = "${node.class}"
        operator  = "="
        value     = "manage"
      }

      resources {
        cpu    = 200
        memory = 128
        network {
          mbits = 3
        }
      }

      template {
        data = <<EOH
interval: 60
repos:
- url: "https://github.com/ketzacoatl/compute-demo/"
  branch: "gfm-nomad"
  watched:
  - files:
      - "nomad-jobs/**"
    # the use of cut and KEY here removes the `foobar-qa` prefix from the
    # path (for the key location in consul)
    #action: "export KEY=$$(echo $$FILE_REL_PATH | cut -d '/' -f 2- -); consulkv cat $$KEY; consulkv put $$KEY < $$FILE_PATH"
    action: "cd nomad-jobs/terraform && terraform init && terraform plan -out=tf.out && terraform apply tf.out && rm -rf tf.out"

        EOH

        destination = "local/nomad-jobs.yaml"
      }
    }
  }
}
