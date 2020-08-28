resource "aws_security_group" "demo-allow-ssh-http" {
  vpc_id      = aws_vpc.demo-main.id
  name        = "demo-allow-ssh"
  description = "security group that allows SSH and HTTP ingress, and all egress traffic"

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

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.demo-elb.id]
  }

  tags = {
    Name = "demo-allow-ssh-http"
  }
}

resource "aws_security_group" "demo-elb" {
  vpc_id      = aws_vpc.demo-main.id
  name        = "elb"
  description = "security group for load balancer"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "demo-elb"
  }
}
