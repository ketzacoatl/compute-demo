# Terraform env for the S3 bucket for storing TF's remote state
variable "region" {
  default     = "us-east-2"
  description = "AWS region to create the bucket in"
}

variable "bucket_name" {
  description = "fill-in"
  type        = "string"
}

provider "aws" {
  region = "${var.region}"
}

module "remote-state" {
  source      = "github.com/fpco/fpco-terraform-aws//tf-modules/s3-remote-state?ref=data-ops-eval"
  bucket_name = "${var.bucket_name}"
  principals  = []
}

// The AWS `region` the bucket has been created in
output "region" {
  value = "${var.region}"
}

// `bucket_id` exported from the `s3-remote-state` module
output "bucket_name" {
  value = "${module.remote-state.bucket_id}"
}
