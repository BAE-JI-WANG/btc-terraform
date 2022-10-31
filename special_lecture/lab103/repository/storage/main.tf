resource "aws_s3_bucket" "tfstat" {
  bucket = var.bucket_name

  force_destroy = true

  lifecycle {
    prevent_destroy = false
  }

  tags = {
    Name        = var.bucket_name
    Environment = var.environment
  }
}


resource "aws_s3_bucket_acl" "tfstat" {
  bucket = aws_s3_bucket.tfstat.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "tfstat" {
  bucket = aws_s3_bucket.tfstat.id
  versioning_configuration {
    status = "Enabled"
  }
}


resource "aws_s3_bucket" "logs" {
  bucket = "${var.bucket_name}-log"

  tags = {
    Name        = "${var.bucket_name}-log"
    Environment = var.environment
  }
}

resource "aws_s3_bucket_acl" "logs" {
  bucket = aws_s3_bucket.logs.id
  acl    = "log-delivery-write"
}

resource "aws_s3_bucket_logging" "this" {
  bucket        = aws_s3_bucket.tfstat.id
  target_bucket = aws_s3_bucket.logs.id
  target_prefix = "logs/${var.bucket_name}"
}