# Terraform env for the DNS zones in use for this env
variable "region" {
  default     = "us-east-2"
  description = "AWS region to setup the provider with"
}

variable "parent_zone_id" {
  description = "ID of the zone (domain) on Route53, if using an existing zone"
  default     = ""
  type        = "string"
}

variable "domain_name" {
  description = "Name of the zone (domain) on Route53, if creating a new zone"
  type        = "string"
}

variable "subdomain_name" {
  description = "This zone will have records auto-generated for the deployments made"
  type        = "string"
}

provider "aws" {
  region = "${var.region}"
}

# If the operator  has  not provided a `parent_zone_id`,         create a new Zone
# If the operator _has_     provided a `parent_zone_id`, _don't_ create a new Zone
resource "aws_route53_zone" "domain" {
  count = "${var.parent_zone_id == "" ? 1 : 0}"
  name  = "${var.domain_name}"
}

module "subdomain" {
  source         = "github.com/fpco/fpco-terraform-aws//tf-modules/r53-subdomain?ref=data-ops-eval"
  name           = "${var.subdomain_name}"
  parent_zone_id = "${var.parent_zone_id}"
}

// The AWS `region` to use with the provider
output "region" {
  value = "${var.region}"
}

// `zone_id` of parent zone/domain
output "parent_zone_id" {
  value = "${var.parent_zone_id}"
}

// `zone_id` exported from the `subdomain` module
output "subdomain_zone_id" {
  value = "${module.subdomain.zone_id}"
}
