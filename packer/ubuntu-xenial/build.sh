#!/usr/bin/env bash

set -ex

SCRIPT_PATH=$(dirname "$(realpath -s "${BASH_SOURCE[0]}")")
PACKER_BASE_PATH="${SCRIPT_PATH}"
PACKER_TEMPLATE="${PACKER_BASE_PATH}/aws/packer-template.json"
AMI_BUILD_TEMP="${PACKER_BASE_PATH}/aws/packer-config.tpl"
AMI_BUILD_CONF="${PACKER_BASE_PATH}/aws/packer-config.json"
SSH_KEY="uploads/id_rsa"

# variables to combine with the build config
# lookup the first few in our terraform build env
cd "${SCRIPT_PATH}/../terraform-vpc"

set +x
[[ -z "${SOURCE_AMI}" ]] && SOURCE_AMI="$(terraform output xenial_ami_id)"
[[ -z "${VPC_ID}"     ]] && VPC_ID="$(terraform output vpc_id)"
[[ -z "${SUBNET_ID}"  ]] && SUBNET_ID="$(terraform output subnet_id)"
[[ -z "${REGION}"     ]] && REGION="$(terraform output region)"
export SOURCE_AMI VPC_ID SUBNET_ID REGION
set -x

envsubst <"${AMI_BUILD_TEMP}" > "${AMI_BUILD_CONF}"
cat "${AMI_BUILD_CONF}"

get_packer() {
    terraform output -json packer-builds \
        | jq -r ".value | .\"${1}\""
}

set +x
[[ -z "${AWS_ACCESS_KEY_ID}"     ]] && AWS_ACCESS_KEY_ID=$(get_packer 'access-key')
[[ -z "${AWS_SECRET_ACCESS_KEY}" ]] && AWS_SECRET_ACCESS_KEY=$(get_packer 'secret')
export AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY
export AWS_DEFAULT_REGION="${REGION}"
set -x

cd "${PACKER_BASE_PATH}"
if [ -f "${SSH_KEY}" ] ; then
  chmod 600 "${SSH_KEY}"
  ssh-keygen -y -f "${SSH_KEY}"
else
  echo "WARNING: no id_rsa SSH key found, generating one.."
  echo "         remove this key later in the build"
  ssh-keygen -t rsa -b 4096 -f "${SSH_KEY}"
fi

packer validate -var-file="${AMI_BUILD_CONF}" "${PACKER_TEMPLATE}"
packer build    -var-file="${AMI_BUILD_CONF}" "${PACKER_TEMPLATE}"
unset AWS_ACCESS_KEY_ID AWS_SECRETS_ACCESS_KEY

jq --raw-output --from-file ami-from-manifest.jq \
   < packer-manifest.json \
   > ami-id.txt
