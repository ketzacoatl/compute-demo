# setup remote state for _this_ env
terraform {
  backend "s3" {
    region = "${REGION}"
    bucket = "${FPD_STATE_BUCKET}"
    key    = "remote-state/terraform.tfstate"
  }
}
