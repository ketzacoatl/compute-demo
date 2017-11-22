variable "name" {
  description = "name of the project, use as prefix to names of resources created"
  default     = "data-ops-eval"
}

variable "region" {
  description = "Region where the project will be deployed"
  default = "us-west-2"
}

variable "ssh_pubkey" {
  description = "File path to SSH public key"
  default     = "./id_rsa.pub"
}

variable "ssh_key" {
  description = "File path to SSH public key"
  default     = "./id_rsa"
}

variable "ami" {
  description = "default AMI, FPCO build for SOA-driven infrastructure"
  default     = "ami-95c715ed"
}

variable "instance_type" {
  description = "map of roles and instance types (VM sizes)"
  default     = {
    "bastion"     = "t2.nano"
  }
}

variable "public_subnet_cidrs" {
  description = "A list of public subnet CIDRs to deploy inside the VPC"
  default     = ["10.23.11.0/24"] #, "10.23.12.0/24", "10.23.13.0/24"]
}

variable "private_subnet_cidrs" {
  description = "A list of private subnet CIDRs to deploy inside the VPC"
  default     = ["10.23.21.0/24"] #, "10.23.22.0/24", "10.23.23.0/24"]
}

variable "vpc_cidr" {
  description = "CIDR for the VPC"
  default     = "10.23.0.0/16"
}
