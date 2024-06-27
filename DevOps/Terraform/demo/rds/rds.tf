resource "aws_db_subnet_group" "demo-rds-subnet" {
  name        = "demo-mysql-subnet"
  description = "RDS subnet group"
  subnet_ids  = [aws_subnet.demo-private-1.id, aws_subnet.demo-private-2.id]
}

resource "aws_db_parameter_group" "demo-rds-parameters" {
  name        = "demo-parameters"
  family      = "mysql8.0"
  description = "MySQL parameter group"

  parameter {
    name  = "max_allowed_packet"
    value = "16777216"
  }
}

resource "aws_db_instance" "demo-mysql" {
  allocated_storage       = 20
  storage_type            = "gp2"
  engine                  = "mysql"
  engine_version          = "8.0"
  instance_class          = "db.t2.micro"
  # note that "mysql" (case insensitive) is a reserved word for this engine
  name                    = "mysqldb"
  identifier              = "demo-mysql"
  username                = var.RDS_USENAME
  password                = var.RDS_PASSWORD
  parameter_group_name    = aws_db_parameter_group.demo-rds-parameters.name
  db_subnet_group_name    = aws_db_subnet_group.demo-rds-subnet.name
  multi_az                = "false"
  vpc_security_group_ids  = [aws_security_group.demo-allow-rds.id]
  backup_retention_period = 30
  availability_zone       = aws_subnet.demo-private-1.availability_zone
  # skip final snapshot when doing terraform destroy
  skip_final_snapshot     = true
  tags = {
    Name = "demo-mysql-instance"
  }
}
