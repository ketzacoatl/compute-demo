//IP of Bastion host in public subnet
output "bastion_ip" {
  value = "${aws_instance.bastion.public_ip}"
}

//The list of IP addresses for the core leaders on EC2
output "core_leader_ips" {
  value = ["${data.template_file.core_leaders_private_ips.*.rendered}"]
}
