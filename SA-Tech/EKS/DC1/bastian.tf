# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

# --- bastian.tf  --- #


data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name = "name"
    values = ["ubuntu/images/*ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}


resource "aws_instance" "bastian" {
  instance_type = "t2.micro"
  ami           = data.aws_ami.ubuntu.id
  vpc_security_group_ids = [
    aws_security_group.bastian_sg.id
  ]
  subnet_id = module.vpc.public_subnets[0]
  key_name  = aws_key_pair.demo.key_name
  tags = {
    Name = "bastion"
  }


}
