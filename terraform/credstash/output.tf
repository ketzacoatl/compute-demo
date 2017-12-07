# Below outputs will be used for automatic credstash usage by EC2 instances
output "kms_key_arn" {
  value = "${module.credstash.kms_key_arn}"
}

// 
output "install_snippet" {
  value = "${module.credstash.install_snippet}"
}

// 
output "get_cmd" {
  value = "${module.credstash.get_cmd}"
}

// 
output "put_cmd" {
  value = "${module.credstash.put_cmd}"
}

// 
output "reader_policy_arn" {
  value = "${module.credstash.reader_policy_arn}"
}

// 
output "writer_policy_arn" {
  value = "${module.credstash.writer_policy_arn}"
}

// 
output "credential_manager_role_arn" {
  value = "${aws_iam_role.credential_manager.arn}"
}
