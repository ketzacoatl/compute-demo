.PHONY: create-packer-vpc destroy-packer-vpc build-ami

.DEFAULT_GOAL = help

## Use Terraform to create a VPC to run packer AMI builds in
create-packer-vpc:
	@$(MAKE) -C packer/terraform-vpc build

## Use Terraform to destroy the VPC used for packer AMI builds
destroy-packer-vpc:
	@$(MAKE) -C packer/terraform-vpc destroy

## Use Packer to build an AMI based on Ubuntu Xenial (16.04)
build-ami:
	@$(MAKE) -C packer/ubuntu-xenial build

## Use Terraform to create a VPC and network for the compute deployment
create-vpc-network:
	@$(MAKE) -C terraform/vpc create-vpc-network

## Show help screen.
help:
	@echo "Please use \`make <target>' where <target> is one of\n\n"
	@awk '/^[a-zA-Z\-\_0-9]+:/ { \
		helpMessage = match(lastLine, /^## (.*)/); \
		if (helpMessage) { \
			helpCommand = substr($$1, 0, index($$1, ":")-1); \
			helpMessage = substr(lastLine, RSTART + 3, RLENGTH); \
			printf "%-30s %s\n", helpCommand, helpMessage; \
		} \
	} \
	{ lastLine = $$0 }' $(MAKEFILE_LIST)
