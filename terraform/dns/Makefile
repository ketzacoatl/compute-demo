.PHONY: render-tf-block render-tfvars init-remote-state plan apply destroy clean

.DEFAULT_GOAL = help

## Use Terraform to review the plan and generate a tf.out file to apply
plan:
	@terraform init
	@terraform plan -out=tf.out


## Use Terraform to apply tf.out
apply:
	@terraform apply tf.out

## Use envsubst and project.env to render terraform-block.tpl into terraform.tf
render-tf-block:
	@. ./project.env && envsubst <terraform-block.tpl > terraform.tf

## Use envsubst and project.env to render terraform-tfvars.tpl into terraform.tfvars
render-tfvars:
	@. ./project.env && envsubst <terraform-tfvars.tpl > terraform.tfvars

## render terraform.tfvars, configure remote state, and re-init to complete the move
init-remote-state: render-tfvars render-tf-block
	@terraform init

## Use Terraform to destroy the VPC and all resources
destroy:
	@terraform init
	@terraform destroy

## rm -rf all state/data files (id_rsa, terraform.tfstate and tfvars)
clean: destroy
	@rm -rf terraform.tfstate terraform.tfstate.backup .terraform
	@rm -rf .terraform terraform.tfvars tf.out terraform.tf


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
