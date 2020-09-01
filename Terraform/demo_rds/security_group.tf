resource "aws_security_group" "demo-allow-ssh" {
  vpc_id      = aws_vpc.demo-main.id
  name        = "demo-allow-ssh"
  description = "security group that allows ssh and all egress traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "demo-allow-ssh"
  }
}

resource "aws_security_group" "demo-allow-rds" {
  vpc_id      = aws_vpc.demo-main.id
  name        = "allow-rds"
  description = "security group that allows RDS"

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    # allowing access from our example instance
    security_groups = [aws_security_group.demo-allow-ssh.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    self        = true
  }

  tags = {
    Name = "demo-allow-rds"
  }
}
