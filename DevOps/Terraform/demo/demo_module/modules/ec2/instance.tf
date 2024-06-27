resource "aws_key_pair" "demo-module" {
  key_name = var.KEY_NAME
  public_key = file(var.PATH_TO_PUBLIC_KEY)
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-trusty-14.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["self"] # Canonical
}

resource "aws_instance" "instance" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.INSTANCE_TYPE

  # choose the first subnet of VPC
  subnet_id = element(var.PUBLIC_SUBNETS, 0)

  # the security group
  vpc_security_group_ids = [aws_security_group.demo-allow-ssh.id]

  # the public SSH key
  key_name = aws_key_pair.demo-module.key_name

  tags = {for key, value in var.PROJECT_TAGS: key => value}
}
