resource "aws_acm_certificate" "ssl" {
  domain_name       = "gachicoding.shop"
  validation_method = "DNS"

  tags = {
    Environment = "ssl_cert"
  }

  lifecycle {
    create_before_destroy = true
  }
}