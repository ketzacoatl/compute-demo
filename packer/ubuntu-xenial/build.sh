#!/usr/bin/env bash

set -ex

PACKER_BASE_PATH="$(pwd)"
PACKER_TEMPLATE="$PACKER_BASE_PATH/aws/packer-template.json"
AMI_BUILD_TEMP="$PACKER_BASE_PATH/aws/packer-config.tpl"
AMI_BUILD_CONF="$PACKER_BASE_PATH/aws/packer-config.json"
SSH_KEY="uploads/id_rsa"

# variables to combine with the build config
# lookup the first few in our terraform build env
cd ../terraform-vpc
export SOURCE_AMI="$(terraform output xenial_ami_id)"
export VPC_ID="$(terraform output vpc_id)"
export SUBNET_ID="$(terraform output subnet_id)"
export REGION="$(terraform output region)"

envsubst <$AMI_BUILD_TEMP > $AMI_BUILD_CONF
cat $AMI_BUILD_CONF

cd $PACKER_BASE_PATH
if [ -f $SSH_KEY ] ; then
  chmod 600 $SSH_KEY
  ssh-keygen -y -f $SSH_KEY
else
  echo "WARNING: no id_rsa SSH key found, generating one.."
  echo "         remove this key later in the build"
  ssh-keygen -t rsa -b 4096 -f $SSH_KEY
fi

#packer build -debug -var-file=$AMI_BUILD_CONF $PACKER_TEMPLATE
packer build -var-file=$AMI_BUILD_CONF $PACKER_TEMPLATE
