resource "aws_instance" "bastion" {
  ami               = "${var.ami}"
  key_name          = "${aws_key_pair.main.key_name}"
  instance_type     = "${var.instance_type["bastion"]}"
  availability_zone = "${data.aws_availability_zones.available.names[0]}"

  root_block_device {
    volume_type = "gp2"
    volume_size = "10"
  }

  associate_public_ip_address = "true"

  vpc_security_group_ids = [
    "${module.public-ssh-sg.id}",
    "${module.open-egress-sg.id}",
  ]

  #iam_instance_profile = "${aws_iam_instance_profile.credstash.name}"

  lifecycle = {
    ignore_changes = ["ami", "user_data"]
  }

  subnet_id = "${module.vpc.public_subnet_ids[0]}"

  tags {
    Name = "${var.name}-bastion"
  }

  user_data = <<END_INIT
#!/bin/bash
echo "hello init"
END_INIT
}
