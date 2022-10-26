# AWS Route53 Zone
resource "aws_route53_zone" "gachicoding_shop" {
 name = "gachicoding.shop"
}

resource "aws_route53_record" "all" {
  zone_id = aws_route53_zone.gachicoding_shop.zone_id
  name    = "gachicoding.shop"
  type    = "A"

  alias {
    name                   = aws_lb.awsome-ap2-web-alb.dns_name
    zone_id                = aws_lb.awsome-ap2-web-alb.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "cert" {
  for_each = {
    for dvo in aws_acm_certificate.ssl.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = aws_route53_zone.gachicoding_shop.zone_id
}