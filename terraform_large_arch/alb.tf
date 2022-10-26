# resource "aws_launch_configuration" "web" {
#   name_prefix     = "lc-web-"
#   image_id        = aws_ami_from_instance.ami.id
#   instance_type   = var.instance_type
#   security_groups = [aws_security_group.web_sg.id]

#   key_name = var.web_key

#   # Required when using a launch configuration with an auto scaling group.
#   lifecycle {
#     create_before_destroy = true
#   }
# }

# resource "aws_autoscaling_group" "web" {
#   name_prefix          = "asg-web-"
#   launch_configuration = aws_launch_configuration.web.name
#   vpc_zone_identifier  = [aws_subnet.large_pri_a.id, aws_subnet.large_pri_c.id]

#   target_group_arns = [aws_lb_target_group.asg.arn]
#   health_check_type = "ELB"

#   min_size = 2
#   max_size = 10

#   tag {
#     key                 = "Name"
#     value               = "tf-asg-web"
#     propagate_at_launch = true
#   }
# }

# resource "aws_lb" "alb" {
#   name               = var.alb_name
#   load_balancer_type = "application"
#   subnets            = [aws_subnet.large_pub_a.id, aws_subnet.large_pub_c.id]
#   security_groups    = [aws_security_group.alb_sg.id]
# }

# resource "aws_lb_listener" "http" {
#   load_balancer_arn = aws_lb.alb.arn
#   port              = var.http
#   protocol          = "HTTP"

#   default_action {
#     type = "fixed-response"

#     fixed_response {
#       content_type = "text/plain"
#       message_body = "404: page not found\n"
#       status_code  = 404
#     }
#   }
# }

# resource "aws_lb_target_group" "asg" {
#   name     = var.alb_name
#   port     = var.http
#   protocol = "HTTP"
#   vpc_id   = aws_vpc.large_vpc.id

#   health_check {
#     path                = "/"
#     protocol            = "HTTP"
#     matcher             = "200"
#     interval            = 15
#     timeout             = 3
#     healthy_threshold   = 2
#     unhealthy_threshold = 2
#   }

#   lifecycle {
#     create_before_destroy = true
#   }
# }

# resource "aws_lb_listener_rule" "asg" {
#   listener_arn = aws_lb_listener.http.arn
#   priority     = 100

#   condition {
#     path_pattern {
#       values = ["*"]
#     }
#   }

#   action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.asg.arn
#   }
# }
