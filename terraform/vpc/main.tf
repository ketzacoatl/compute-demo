provider "aws" {
  region = "${var.region}"
}

terraform {
  required_version = "= 0.11.0"
}

resource "aws_key_pair" "main" {
  key_name   = "${var.name}"
  public_key = "${file(var.ssh_pubkey)}"
}
