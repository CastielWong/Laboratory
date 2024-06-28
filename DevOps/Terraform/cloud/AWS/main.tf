
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "ap-southeast-1"
}

resource "aws_instance" "app_server" {
  ami           = "ami-008c09a18ce321b3c"
  instance_type = "t2.micro"

  key_name               = aws_key_pair.deployer.key_name
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]

  tags = {
    Name = "Demo"
    DEMO = "Terraform"
  }
}

resource "aws_key_pair" "deployer" {
  key_name   = "terraform-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDQdXBlbQ+FBR5PIqj4PjpRKfxOZAOHelx+9erZn7iP/vZ4T6W/YTtlDShAS7FzXf1Km55vLrrK3S03c1gMrEcWy6HxxD0taB4h+M/nnNz4zsScmnCrZK36j8V5PszGkCf7vGNkyThHjLUcMWV9d7ts7LYe3hzDVJrdPsfeousu+GHfcqLOMDSkXv95DXG6NJVGGjdrz6qVDhjwAv61kzo0HtV4UZ1DTuCmZsgdTD4Uf3cqIVMXngp/A9m8xixx4eqFZVrkOGEbxSxlwKPDrHnJAY3OV0Sq3kJcpk5/I0hG6En8MWs1GiA0cCifZCQyz1ZcULJEmaifPhlV2OTBdVrN caswexp2024q2@gmail.com"

  tags = {
    DEMO = "Terraform"
  }
}

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic and all outbound traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # for public access
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }


  tags = {
    Name = "Demo"
    DEMO = "Terraform"
  }
}
