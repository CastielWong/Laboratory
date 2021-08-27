
resource "aws_s3_bucket" "codebuild-cache" {
  bucket = var.BUCKET_CACHE_NAME
  acl    = "private"
}

resource "aws_s3_bucket" "demo-artifacts" {
  bucket = var.BUCKET_ARTIFACT_NAME
  acl    = "private"

  lifecycle_rule {
    id      = "clean-up"
    enabled = "true"

    expiration {
      days = 30
    }
  }
}
