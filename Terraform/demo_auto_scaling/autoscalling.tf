resource "aws_key_pair" "demo-auto-scaling" {
  key_name = var.KEY_NAME
  public_key = file("../${var.KEY_NAME}.pub")
  lifecycle {
    ignore_changes = [public_key]
  }
}

resource "aws_launch_configuration" "demo-launchconfig" {
  name_prefix     = "demo-launchconfig"
  image_id        = var.AMIS[var.AWS_REGION]
  instance_type   = "t2.micro"
  key_name        = aws_key_pair.demo-auto-scaling.key_name
  security_groups = [aws_security_group.demo-allow-ssh.id]
}

resource "aws_autoscaling_group" "demo-autoscaling" {
  name                      = "demo-autoscaling"
  vpc_zone_identifier       = [aws_subnet.demo-public-1.id, aws_subnet.demo-public-2.id]
  launch_configuration      = aws_launch_configuration.demo-launchconfig.name
  min_size                  = "1"
  max_size                  = "2"
  health_check_grace_period = "300"
  health_check_type         = "EC2"
  force_delete              = true

  tag {
    key                 = "Name"
    value               = "EC2 instance"
    propagate_at_launch = true
  }
}
