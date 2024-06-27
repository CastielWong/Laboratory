resource "aws_s3_bucket" "demo-bucket" {
  bucket = var.BUCKET_NAME
  acl    = "private"

  tags = {
    Name = var.BUCKET_NAME
  }
}
