output "instance" {
  value = aws_instance.demo-rds.public_ip
}

output "rds" {
  value = aws_db_instance.demo-mariadb.endpoint
}
