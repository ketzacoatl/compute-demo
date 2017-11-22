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

# shared security group for SSH (from within the VPC)
module "private-ssh-sg" {
  source              = "github.com/fpco/fpco-terraform-aws//tf-modules/ssh-sg?ref=data-ops-eval"
  name                = "${var.name}-private"
  vpc_id              = "${module.vpc.vpc_id}"
  allowed_cidr_blocks = ["${var.vpc_cidr}"]
}

# shared security group for SSH (public access)
module "public-ssh-sg" {
  source              = "github.com/fpco/fpco-terraform-aws//tf-modules/ssh-sg?ref=data-ops-eval"
  name                = "${var.name}-public"
  vpc_id              = "${module.vpc.vpc_id}"
  allowed_cidr_blocks = ["0.0.0.0/0"]
}

# shared security group, open egress (outbound from nodes)
module "open-egress-sg" {
  source              = "github.com/fpco/fpco-terraform-aws//tf-modules/open-egress-sg?ref=data-ops-eval"
  name   = "${var.name}"
  vpc_id = "${module.vpc.vpc_id}"
}
