# Outputs
# output "public_ip" {
#   value       = "${aws_instance.web.public_ip}:${var.server_port_http}"
#   description = "Webserver PIP"
# }

# output "private_ip" {
#   value = aws_instance.web.private_ip
# }

# Datas
# data "template_file" "userdata" {
#   template = file("userdata.tpl")
#   vars = {
#     HTTP  = var.server_port_http
#   }
# }

# output "account_id" {
#   value = data.aws_caller_identity.current.account_id
# }

# output "caller_arn" {
#   value = data.aws_caller_identity.current.arn
# }

# output "caller_user" {
#   value = data.aws_caller_identity.current.user_id
# }

output "alb_dns_name" {
  value = aws_lb.alb.dns_name
}