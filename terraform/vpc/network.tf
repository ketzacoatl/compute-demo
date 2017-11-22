module "vpc" {
  source      = "github.com/fpco/fpco-terraform-aws//tf-modules/vpc-scenario-2?ref=data-ops-eval"
  name_prefix = "${var.name}"
  region      = "${var.region}"
  cidr        = "${var.vpc_cidr}"
  azs         = ["${slice(data.aws_availability_zones.available.names, 0, 3)}"]
  extra_tags  = { kali = "ma" }
  public_subnet_cidrs  = ["${var.public_subnet_cidrs}"]
  private_subnet_cidrs = ["${var.private_subnet_cidrs}"]
}
