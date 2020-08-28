resource "aws_db_subnet_group" "demo-rds-subnet" {
  name        = "demo-mariadb-subnet"
  description = "RDS subnet group"
  subnet_ids  = [aws_subnet.demo-private-1.id, aws_subnet.demo-private-2.id]
}

resource "aws_db_parameter_group" "demo-rds-parameters" {
  name        = "demo-mariadb-parameters"
  family      = "mariadb10.1"
  description = "MariaDB parameter group"

  parameter {
    name  = "max_allowed_packet"
    value = "16777216"
  }
}

resource "aws_db_instance" "demo-mariadb" {
  allocated_storage       = 20
  storage_type            = "gp2"
  engine                  = "mariadb"
  engine_version          = "10.1.14"
  instance_class          = "db.t2.micro"
  name                    = "mariadb"
  identifier              = "mariadb"
  username                = var.RDS_USENAME
  password                = var.RDS_PASSWORD
  parameter_group_name    = aws_db_parameter_group.demo-rds-parameters.name
  db_subnet_group_name    = aws_db_subnet_group.demo-rds-subnet.name
  multi_az                = "false"
  vpc_security_group_ids  = [aws_security_group.demo-allow-mariadb.id]
  backup_retention_period = 30
  availability_zone       = aws_subnet.demo-private-1.availability_zone
  # skip final snapshot when doing terraform destroy
  skip_final_snapshot     = true
  tags = {
    Name = "demo-mariadb-instance"
  }
}
