.PHONY: build destroy

.DEFAULT_GOAL = help

## Use Terraform to create a VPC to run packer AMI builds in
build:
	@terraform init
	@terraform plan -out=tf.out
	@terraform apply tf.out
	@rm -rf tf.out

## Use Terraform to destroy the VPC used for packer AMI builds
destroy:
	@terraform init
	@terraform plan -out=tf.out -destroy
	@terraform apply tf.out
	@rm -rf tf.out


