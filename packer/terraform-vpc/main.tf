provider "aws" {
  version = "~> 1.9"
  region  = "${var.region}"
}

module "vpc" {
  source = "github.com/fpco/fpco-terraform-aws//packer/terraform-vpc?ref=master"
  region = "${var.region}"
}

variable "region" {
  default = "us-west-2"
}

// region
output "region" {
  value = "${var.region}"
}

// VPC ID
output "vpc_id" {
  value = "${module.vpc.vpc_id}"
}

// Subnet ID
output "subnet_id" {
  value = "${module.vpc.subnet_id}"
}

// ID of latest xenial AMI
output "xenial_ami_id" {
  value = "${module.vpc.xenial_ami_id}"
}
