# Data Ops Evaluation

The goal of this test project is to evaluate various "big data" and "distributed
compute" tools/services/apps/frameworks/products. Run in a test/lab environment,
but aiming to base the code on production-quality infrastructure (run on AWS).


## How to Get Started

### Start with an S3 Bucket

We have a few dependencies before we can really get into it. An S3 bucket is our
first dependency. This bucket will store remote state and serve as a central
point for tracking various details about the infrastructure.

```
ᐅ cd terraform/remote-state
```

```
ᐅ # determine: which region do we create this in
ᐅ echo "export REGION=us-west-2" >> project.env
```

```
ᐅ # determine: what is the name of the bucket? a random/non-meaningful name is fine
ᐅ echo "export FPD_STATE_BUCKET=fafsd213-state-store" >> project.env
```

```
ᐅ
ᐅ make init-bucket
ᐅ make plan
ᐅ make apply
```


### Setup a Subdomain

We will be deploying a bunch of different services, some of which we'll want to
access via a web UI. We will register these services with DNS records in a
subdomain hosted on Route53.

```
ᐅ cd terraform/dns
```

```
ᐅ # export region, remote state bucket name, subdomain name, and either zone_id or domain_name
ᐅ echo "export REGION=us-west-2" >> project.env
ᐅ echo "export FPD_STATE_BUCKET=fafsd213-state-store" >> project.env
ᐅ echo "export SUBDOMAIN_NAME=compute.sandbox.example.com" >> project.env
ᐅ echo "export PARENT_ZONE_ID=Z1AFD1191A29C8" >> project.env
ᐅ # leave DOMAIN_NAME set to empty double quotes for none, provide a valid name if not using zone_id
ᐅ echo "export DOMAIN_NAME=\"\"" >> project.env
```

```
ᐅ
ᐅ make init-remote-state
ᐅ make plan
ᐅ make apply
```

After that plan is applied, you should see something like:

```
module.subdomain.aws_route53_record.subdomain-NS: Still creating... (30s elapsed)
module.subdomain.aws_route53_record.subdomain-NS: Still creating... (40s elapsed)
module.subdomain.aws_route53_record.subdomain-NS: Creation complete after 41s (ID: Z142JA4AA87DW_compute.sandbox.example.com_NS)

Apply complete! Resources: 2 added, 0 changed, 0 destroyed.

Outputs:

parent_zone_id = Z142JA4AA87DW
region = us-west-2
subdomain_zone_id = Z6AM2L8RLA8X45
```

### Create a Space to Build an AMI

```
ᐅ cd packer/terraform-vpc
ᐅ # do whatever you do to get (temp) credentials
ᐅ get-aws-creds
ᐅ terraform init
ᐅ # create terraform.tfvars if you want to customize the variables
ᐅ echo 'region = "us-east-2"' > terraform.tfvars
ᐅ terraform apply
```

Review the plan, tell Terraform to proceed if you like the plan, and you should
see some output like the following:

```
...
Apply complete! Resources: 5 added, 0 changed, 0 destroyed.

Outputs:

region = us-east-2
subnet_id = subnet-49da2721
vpc_id = vpc-2e4fa646
xenial_ami_id = ami-82f4dae7
```

`xenial_ami_id` is an output from the Terraform project, pointing us to the
current/most recent Ubuntu Xenial AMI in our target region. This is the AMI that
will be used as the "source AMI" when we build a custom AMI with Packer.

The `vpc_id` and `subnet_id` are other outputs that our Packer build will use,
this is the secure network within which our Packer builds will run.


### Build an AMI

```
ᐅ cd packer/ubuntu-xenial
ᐅ # modify build.env if you wish
ᐅ $EDITOR build.env
ᐅ make build
```

You will eventually see the packer build complete with:

```
...
==> amazon-ebs: Stopping the source instance...
==> amazon-ebs: Waiting for the instance to stop...
==> amazon-ebs: Creating the AMI: base-host-2017-11-29T16-54-00Z
    amazon-ebs: AMI: ami-b87f56dd
==> amazon-ebs: Waiting for AMI to become ready...
==> amazon-ebs: Adding tags to AMI (ami-b87f56dd)...
==> amazon-ebs: Tagging snapshot: snap-038fb897e868e0b81
==> amazon-ebs: Creating AMI tags
    amazon-ebs: Adding tag: "Name": "fpco-base"
    amazon-ebs: Adding tag: "Time_Stamp": "2017-11-29T16-54-00Z"
    amazon-ebs: Adding tag: "Desc": "Stock Ubuntu 16.04 + FPC common base for SOA-driven infrastructure"
    amazon-ebs: Adding tag: "OS_Version": "Ubuntu Xenial"
    amazon-ebs: Adding tag: "Release": "16.04 LTS"
    amazon-ebs: Adding tag: "Build_ID": "2017-11-29-gitrev"
==> amazon-ebs: Creating snapshot tags
==> amazon-ebs: Terminating the source AWS instance...
==> amazon-ebs: Cleaning up any extra volumes...
==> amazon-ebs: No volumes to clean up, skipping
==> amazon-ebs: Deleting temporary security group...
==> amazon-ebs: Deleting temporary keypair...
Build 'amazon-ebs' finished.

==> Builds finished. The artifacts of successful builds are:
--> amazon-ebs: AMIs were created:

us-east-2: ami-b87f56dd
```

This AMI, `ami-b87f56dd` in our example, is the custom AMI built by Packer,
available in our target region (we could copy to multiple regions, but this
example doesn't do that). We will use this AMI to run EC2 instances.


### Secrets, the Last Dependencies

Run `make depends` to generate some secrets:

```
ᐅ cd terraform/vpc
ᐅ make depends
```

Put those into a `terraform.tfvars`, this is also the time to add in the `ami`
from the packer build. Review `variables.tf` for other knobs available. At
minimum, `terraform.tfvars` would look like:

```
nomad_secret = "mdoxO5ZO4agRPqQ/Mx67cQ=="
consul_secret_key = "O0AtcUelLRVJ2P851Jgdlw=="
consul_master_token = "a54df813-ad81-4b7e-b4d7-5a2344b6796c"
ami = "ami-b87f56dd"
```

### Create the VPC Network

```
ᐅ cd terraform/vpc
ᐅ get-aws-creds
ᐅ make create-vpc-network
```


### Run the Compute Cluster

```
ᐅ make plan
ᐅ make apply
```

### SSH in and poke around

```
ᐅ make scp-ssh-key
id_rsa                         100% 3243     3.2KB/s   00:00
ᐅ make ssh-bastion
...
ubuntu@core-leaders-i-051b38f018dc9ba9e:~$
```

Poke around with a few tools:

* `nomad status`
* `consul members`
* `nomad node-status`
* `nomad server-members`
* `consul monitor`
* `journalctl -u nomad`

That might look like:

```
ubuntu@core-leaders-i-051b38f018dc9ba9e:~$ sudo su -l
root@core-leaders-i-051b38f018dc9ba9e:~# consul members
Node                              Address            Status  Type    Build  Protocol  DC                  Segment
core-leaders-i-051b38f018dc9ba9e  10.23.21.4:8301    alive   server  1.0.0  2         poc-demo-us-east-2  <all>
fabio-i-0aae1e4b36500769b         10.23.21.191:8301  alive   client  1.0.0  2         poc-demo-us-east-2  <default>
manage-i-00fb083352e1828f4        10.23.21.213:8301  alive   client  1.0.0  2         poc-demo-us-east-2  <default>
workers-i-00567713bd2050fa9       10.23.21.11:8301   alive   client  1.0.0  2         poc-demo-us-east-2  <default>
root@core-leaders-i-051b38f018dc9ba9e:~# nomad status
No running jobs
root@core-leaders-i-051b38f018dc9ba9e:~# nomad node-status
ID        DC                  Name                         Class          Drain  Status
f4c53b17  poc-demo.us-east-2  fabio-i-0aae1e4b36500769b    load-balancer  false  ready
e232cde6  poc-demo.us-east-2  workers-i-00567713bd2050fa9  compute        false  ready
51be4f38  poc-demo.us-east-2  manage-i-00fb083352e1828f4   manage         false  ready
```

## Credstash, TLS, and Other Credentials

This section is not yet complete, move up and integrate into previous sections
when it is ready for primetime.

### Setup Credstash

We will be deploying a bunch of different services, some of which we'll want to
access via a web UI. We will register these services with DNS records in a
subdomain hosted on Route53.

```
ᐅ cd terraform/credstash
```

```
ᐅ # export region, remote state bucket name, and project name
ᐅ echo "export REGION=us-west-2" >> project.env
ᐅ echo "export FPD_STATE_BUCKET=fafsd213-state-store" >> project.env
ᐅ echo "export NAME=compute-poc" >> project.env
```

```
ᐅ
ᐅ make init-remote-state
ᐅ make plan
ᐅ make apply
```

After that plan is applied, you should see something like:

```
...
module.credstash.aws_kms_alias.credstash-key: Creation complete after 2s (ID: alias/compute-poc)
module.credstash.data.template_file.credstash-put-cmd: Refreshing state...
module.credstash.aws_dynamodb_table.credstash-db: Still creating... (10s elapsed)
module.credstash.aws_dynamodb_table.credstash-db: Creation complete after 15s (ID: compute-poc)

Apply complete! Resources: 5 added, 0 changed, 0 destroyed.

Outputs:

get_cmd = env credstash -r us-west-2 -t compute-poc get
install_snippet = { apt-get update;
  apt-get install -y build-essential libssl-dev libffi-dev python-dev python-pip;
  pip install --upgrade pip;
  pip install credstash; }
...
```

### Test Credstash

Let's test `credstash` and/or `gcredstash`. I could use `gcredstash` as an
operator, while my EC2 instances continue to use `credstash`, they are compatible
tools:

* [`credstash`](https://github.com/fugue/credstash)
* [`gcredstash`](https://github.com/winebarrel/gcredstash),
  [static executable downloads](https://github.com/winebarrel/gcredstash/releases)

Here we will create / list / get a few secrets.

Let's first define some variables in our shell env so we don't need to restate
these details each time we invoke the tool:

```
ᐅ export AWS_REGION=us-west-2
ᐅ export GCREDSTASH_TABLE=compute-poc
ᐅ export GCREDSTASH_KMS_KEY=alias/compute-poc
```

The credstash table in Dynamo is currently empty:

```
ᐅ gcredstash list

ᐅ
```

Let's add a secret:

```
ᐅ gcredstash put my-secret pass123
my-secret has been stored

```

And retrieve it:

```
ᐅ gcredstash list
my-secret -- version: 1
ᐅ gcredstash get my-secret
pass123
```

Deleting that secret:

```
ᐅ gcredstash delete my-secret
Deleting my-secret -- version 1
ᐅ gcredstash list

ᐅ
```

We can also use the secret's "context" to limit who has access to the value.
That would look like:

```
ᐅ gcredstash put -h
usage: gcredstash put [-k KEY] [-v VERSION] [-a] credential value [context [context ...]]
```

Or:

```
ᐅ gcredstash put secret-key SuP3rS33krat role=compute
secret-key has been stored
```

```
ᐅ gcredstash get secret-key role=compute
SuP3rS33krat
```


## Blabbity-blab

### Apps / Tools up for consideration:

* TensorFlow
* Kafka
* Storm
* Neo4j
* StreamSets
* Apache Flume
* Spark
* AWS Redshift
* Elasticsearch


### Goals

* get experience setting up a few data ops tools/services
* demonstrate some meaningful examples, "toy" examples similar to expected use
* create some code we can re-use, or use as examples to demonstrate implementation


### Interesting Targets

* dynamic, load-based, autoscaling cluster
* screenshot web uis available
* track all files/scripts/setup steps/etc to make it happen
* map out one or more meaningful demonstrations that pull together (preferrably)
  several data ops tools into a pipeline or collection of services, examples:
    * run tensorflow image recognition library
    * follow some twitter stream, with different types of analysis running on
      incoming events in parallel
    * run batch-type analysis on stored data / results
    * application log analysis and storage
    * log-centric web app demo
