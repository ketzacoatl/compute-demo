.PHONY: build destroy

.DEFAULT_GOAL = help

## Use Terraform to create a VPC to run packer AMI builds in
build:
	@terraform init
	@terraform apply

## Use Terraform to destroy the VPC used for packer AMI builds
destroy:
	@terraform init
	@terraform apply -destroy

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
