resource "aws_security_group" "demo-allow-ssh" {
  vpc_id      = var.VPC_ID
  name        = "demo-allow-ssh-${var.ENV}"
  description = "security group that allows ssh and all egress traffic"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {for key, value in var.PROJECT_TAGS: key => value}
}
