resource "aws_key_pair" "demo-s3" {
  key_name = var.KEY_NAME
  public_key = file("../${var.KEY_NAME}.pub")
}

resource "aws_instance" "demo-s3" {
  ami           = var.AMIS[var.AWS_REGION]
  instance_type = "t2.micro"

  # the VPC subnet
  subnet_id = aws_subnet.demo-public-1.id
  private_ip = "10.0.1.30"

  vpc_security_group_ids = [aws_security_group.demo-allow-ssh.id]

  key_name = aws_key_pair.demo-s3.key_name

  iam_instance_profile = aws_iam_instance_profile.s3-mybucket-role-instanceprofile.name
}
