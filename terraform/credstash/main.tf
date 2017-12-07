# Terraform env for the S3 bucket for storing TF's remote state

variable "region" {
  default     = "us-east-2"
  description = "AWS region to use witht the provider"
}

variable "name" {
  description = "name of our project"
  type        = "string"
}

provider "aws" {
  region = "${var.region}"
}

module "credstash" {
  source               = "github.com/fpco/fpco-terraform-aws//tf-modules/credstash-setup?ref=data-ops-eval"
  create_reader_policy = true # can be ommitted if secrets are writeonly from within EC2
  create_writer_policy = true # can be ommitted if secrets are readonly from within EC2
  db_table_name        = "${var.name}"
  kms_key_name         = "${var.name}"
}
