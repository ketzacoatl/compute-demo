.PHONY: create-vpc-network plan apply generate-ssh-keypair

.DEFAULT_GOAL = help

## Use Terraform to create a VPC and network for the compute deployment
create-vpc-network:
	@terraform init
	@terraform plan -out=tf.out -target=module.vpc.module.public-subnets
	@terraform apply tf.out
	@terraform plan -out=tf.out -target=module.vpc.module.private-subnets
	@terraform apply tf.out
	@terraform plan -out=tf.out -target=module.vpc.module.public-gateway
	@terraform apply tf.out
	#@terraform plan -out=tf.out -target=module.vpc.module.nat-gateway
	#@terraform apply tf.out
	@rm -rf tf.out

## Use Terraform to review the plan and generate a tf.out file to apply
plan:
	@terraform init
	@aws-env terraform plan -out=tf.out

## Use Terraform to apply tf.out
apply:
	@aws-env terraform apply tf.out

## Use Terraform to destroy the VPC and all resources
destroy:
	@terraform init
	@terraform plan -out=tf.out -destroy
	@terraform apply tf.out
	@rm -rf tf.out

## Generate new ssh keypair
generate-ssh-keypair:
	@ssh-keygen -t rsa -b 4096 -f $$PWD/id_rsa

## Generate Nomad Secret Key (3, you can pick one)
generate-nomad-secret-keys:
	@docker run -it vancluever/nomad keygen
	@docker run -it vancluever/nomad keygen
	@docker run -it vancluever/nomad keygen

## Generate Consul Secret Key (3, you can pick one)
generate-consul-secret-keys:
	@docker run -it --entrypoint /bin/consul progrium/consul keygen
	@docker run -it --entrypoint /bin/consul progrium/consul keygen
	@docker run -it --entrypoint /bin/consul progrium/consul keygen

## Generate Master Token for Consul
generate-consul-master-token:
	@python -c "import uuid; print uuid.uuid4()"
	@python -c "import uuid; print uuid.uuid4()"
	@python -c "import uuid; print uuid.uuid4()"

## Taint the leader instances
taint-core-leaders:
	@terraform taint -module core-leaders aws_instance.auto-recover

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
