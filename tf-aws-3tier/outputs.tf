output "alb_dns" {
  value = aws_lb.awsome-ap2-web-alb.dns_name
}

# output "nlb_dns" {
#   value = module.awsome-ap2-was-nlb.lb_dns_name
# }

output "cert_arn" {
  value = aws_acm_certificate.ssl.arn
}