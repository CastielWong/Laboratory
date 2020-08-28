resource "aws_key_pair" "demo-rds" {
  key_name = var.KEY_NAME
  public_key = file("../${var.KEY_NAME}.pub")
}

resource "aws_instance" "demo-rds" {
  ami           = var.AMIS[var.AWS_REGION]
  instance_type = "t2.micro"

  # the VPC subnet
  subnet_id = aws_subnet.demo-public-1.id

  # the security group
  vpc_security_group_ids = [aws_security_group.demo-allow-ssh.id]

  # the public SSH key
  key_name = aws_key_pair.demo-rds.key_name
}
