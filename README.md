# Data Ops Evaluation

The goal of this test project is to evaluate various "big data" and "distributed
compute" tools/services/apps/frameworks/products. Run in a test/lab environment,
but aiming to base the code on production-quality infrastructure (run on AWS).


## How to Get Started

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
