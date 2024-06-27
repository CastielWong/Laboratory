resource "aws_key_pair" "demo-tf" {
  key_name = var.KEY_NAME
  public_key = file("../${var.KEY_NAME}.pub")
}

resource "aws_instance" "demo-template" {
  ami           = var.AMIS[var.AWS_REGION]
  instance_type = "t2.micro"

  # the VPC subnet
  subnet_id = aws_subnet.demo-public-1.id

  # the security group
  vpc_security_group_ids = [aws_security_group.demo-allow-ssh.id]

  # the public SSH key
  key_name = aws_key_pair.demo-tf.key_name

  # user data
  user_data = data.template_cloudinit_config.demo-cloudinit.rendered
}

resource "aws_ebs_volume" "demo-ebs-volume" {
  availability_zone = "${var.AWS_REGION}a"
  size              = 10
  type              = "gp2"
  tags = {
    Name = "demo extra volume"
  }
}

resource "aws_volume_attachment" "demo-ebs-volume-attachment" {
  device_name  = var.INSTANCE_DEVICE_NAME
  volume_id    = aws_ebs_volume.demo-ebs-volume.id
  instance_id  = aws_instance.demo-template.id
  # do not skip destroy unless files in EBS are needed
  skip_destroy = false
}
