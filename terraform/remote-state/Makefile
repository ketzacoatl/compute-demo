.PHONY: render-tf-block render-tfvars init-bucket plan apply destroy clean

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

## Run this the first time - Render tfvars, create the S3 bucket, set it up for remote state, and re-init to push our local state to the remote bucket
init-bucket: render-tfvars plan apply render-tf-block
	@terraform init
	@terraform plan -out=tf.out
	@terraform apply tf.out
	@echo "here is a list of the outputs for this Terraform project:"
	@terraform output
	@echo "here is a recursive ls on the bucket:"
	@AWS_DEFAULT_REGION=$$(terraform output region) aws s3 ls --recursive s3://$$(terraform output bucket_name)/
	@echo "all done, see the outputs above!"

## Use Terraform to destroy the VPC and all resources
destroy:
	@echo "\n\n\nWARNING!!! THIS IS WILL DESTROY ALL STATE FILES IN THE BUCKET AND THE BUCKET ITSELF\n\n\n"
	@echo "the purge happens before destory, so you'll see a confirmation if you want to continue, but it's already too late by then :P"
	@ops aws s3 purge --region $$(terraform output region) --delete $$(terraform output bucket_name)
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
