
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

  default_tags {
    tags = {
      DEMO = "Terraform"
    }
  }
}

# -----------------------------------------------------------------------------
# IAM
resource "aws_iam_user" "terraform_user" {
  name = "terraform_user"

  tags = {
    Name = "TerraformUser"
  }
}
resource "aws_iam_role" "terraform_role" {
  name = "terraform_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          # Service = "ec2.amazonaws.com"
          AWS = "${aws_iam_user.terraform_user.arn}"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "TerraformRole"
  }
}
resource "aws_iam_role_policy" "terraform_role_policy" {
  name = "terraform-role-policy"
  role = aws_iam_role.terraform_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ec2:*",
          "s3:*",
          "iam:*"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_policy" "terraform_assume_role" {
  name        = "assume-role-policy"
  description = "Policy used to allow assuming role"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = "sts:AssumeRole",
        Resource = aws_iam_role.terraform_role.arn
      }
    ]
  })
}
resource "aws_iam_user_policy_attachment" "terraform_user_role_policy_attachment" {
  # attach the role to user via policy
  user       = aws_iam_user.terraform_user.name
  policy_arn = aws_iam_policy.terraform_assume_role.arn
}


# IAM Instance Profile for EC2 instances to assume the role
resource "aws_iam_instance_profile" "terraform_role" {
  name = "terraform_role"
  role = aws_iam_role.terraform_role.name
}

# -----------------------------------------------------------------------------
# EC2
resource "aws_instance" "app_server" {
  ami           = "ami-008c09a18ce321b3c"
  instance_type = "t2.micro"

  key_name               = aws_key_pair.deployer.key_name
  subnet_id              = aws_subnet.deployer.id
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]
  iam_instance_profile   = aws_iam_instance_profile.terraform_role.name

  tags = {
    Name = "DemoTerraform"
  }
}

resource "aws_key_pair" "deployer" {
  key_name   = "terraform-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDQdXBlbQ+FBR5PIqj4PjpRKfxOZAOHelx+9erZn7iP/vZ4T6W/YTtlDShAS7FzXf1Km55vLrrK3S03c1gMrEcWy6HxxD0taB4h+M/nnNz4zsScmnCrZK36j8V5PszGkCf7vGNkyThHjLUcMWV9d7ts7LYe3hzDVJrdPsfeousu+GHfcqLOMDSkXv95DXG6NJVGGjdrz6qVDhjwAv61kzo0HtV4UZ1DTuCmZsgdTD4Uf3cqIVMXngp/A9m8xixx4eqFZVrkOGEbxSxlwKPDrHnJAY3OV0Sq3kJcpk5/I0hG6En8MWs1GiA0cCifZCQyz1ZcULJEmaifPhlV2OTBdVrN caswexp2024q2@gmail.com"
}

resource "aws_security_group" "allow_ssh" {
  vpc_id      = aws_vpc.deployer.id
  name        = "terraform_ssh"
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
    Name = "DemoTerraform"
  }
}

# -----------------------------------------------------------------------------
# VPC
resource "aws_vpc" "deployer" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "terraform-vpc"
  }
}

resource "aws_internet_gateway" "deployer" {
  vpc_id = aws_vpc.deployer.id

  tags = {
    Name = "terraform-internet-gw"
  }
}

resource "aws_route_table" "deployer" {
  vpc_id = aws_vpc.deployer.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.deployer.id
  }

  tags = {
    Name = "terraform-route-table"
  }
}
resource "aws_subnet" "deployer" {
  vpc_id                  = aws_vpc.deployer.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-southeast-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "terraform-subnet"
  }
}
resource "aws_route_table_association" "deployer" {
  subnet_id      = aws_subnet.deployer.id
  route_table_id = aws_route_table.deployer.id
}

# -----------------------------------------------------------------------------
# S3
resource "aws_s3_bucket" "terraform_bucket" {
  bucket = "terraform-caswexp2024q2" # must be a unique bucket name

  tags = {
    Name = "terraform_bucket"
  }
}
# resource "aws_s3_bucket_policy" "bucket_policy" {
#   bucket = aws_s3_bucket.terraform_bucket.id

#   # allow EC2 instance access
#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect    = "Allow"
#         Principal = "*"
#         Action    = "s3:*"
#         Resource = [
#           "${aws_s3_bucket.terraform_bucket.arn}",
#           "${aws_s3_bucket.terraform_bucket.arn}/*",
#         ]
#       }
#     ]
#   })
# }
