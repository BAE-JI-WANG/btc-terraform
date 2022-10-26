# ALB
resource "aws_lb" "awsome-ap2-web-alb" {
  name                             = "awsome-ap2-web-alb"
  internal                         = false
  load_balancer_type               = "application"
  security_groups                  = [aws_security_group.awesome-ap2-web-alb-sg.id]
  subnets                          = [aws_subnet.awesome-ap-pub-sub-2a.id, aws_subnet.awesome-ap-pub-sub-2c.id]
  enable_cross_zone_load_balancing = true
  tags = {
    "Name" = "awesome-ap2-web-alb"
  }
}

# Target Group
resource "aws_lb_target_group" "awsome-ap2-web-tg" {
  name_prefix = "webtg-"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.awesome-vpc.id
  depends_on = [
    aws_nat_gateway.awesome-ap2-nat
  ]

  lifecycle {
    create_before_destroy = true
  }


  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 15
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2

  }

  tags = {
    "Name" = "awsome-ap2-web-tg"
  }
}

# resource "aws_lb_target_group_attachment" "awsome-ap2-web-tg-att" {
#   target_group_arn = aws_lb_target_group.awsome-ap2-web-tg.arn
#   target_id        = aws_autoscaling_group.awsome-ap2-web-as.id
#   port             = 80
# }

# lb_listener
resource "aws_lb_listener" "awsome-ap2-web-alb-listen" {
  load_balancer_arn = aws_lb.awsome-ap2-web-alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.ssl.arn

  default_action {
    type             = "fixed-response"
    target_group_arn = aws_lb_target_group.awsome-ap2-web-tg.arn

    fixed_response {
      content_type = "text/plain"
      message_body = "404: 페이지가 안나온다!"
      status_code  = 404
    }
  }
}

# resource "aws_lb_listener" "https" {
#   load_balancer_arn = aws_lb.awsome-ap2-web-alb.arn
#   port              = "443"
#   protocol          = "HTTPS"
#   ssl_policy        = "ELBSecurityPolicy-2016-08"
#   certificate_arn   = aws_acm_certificate.ssl.arn

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.awsome-ap2-web-tg.arn
#   }
# }

resource "aws_lb_listener_rule" "awsome-ap2-web-alb-listener-rule" {
  listener_arn = aws_lb_listener.awsome-ap2-web-alb-listen.arn
  priority     = 100

  condition {
    path_pattern {
      values = ["*"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.awsome-ap2-web-tg.arn
  }
}

# Launch Configuration
resource "aws_launch_configuration" "awsome-ap2-web-conf" {
  name_prefix   = "awsome-ap2-web-"
  image_id      = var.web_ami
  instance_type = "t2.micro"
  key_name      = var.web_key
  # user_data       = file("web.sh")
  # user_data       = templatefile("web.tftpl", { nlb_dns = module.awsome-ap2-was-nlb.lb_dns_name })
  user_data       = templatefile("web.tftpl", { nlb_dns = aws_lb.awsome-ap2-was-nlb.dns_name })
  security_groups = [aws_security_group.awesome-ap2-web-sg.id]
  lifecycle {
    create_before_destroy = true
  }
}

# Auto Scaling group

resource "aws_autoscaling_group" "awsome-ap2-web-as" {
  name_prefix          = "awsome-ap2-web-as-"
  launch_configuration = aws_launch_configuration.awsome-ap2-web-conf.name
  vpc_zone_identifier  = [aws_subnet.awesome-ap-web-sub-2a.id, aws_subnet.awesome-ap-web-sub-2c.id]

  target_group_arns = [aws_lb_target_group.awsome-ap2-web-tg.arn]
  health_check_type = "ELB"

  desired_capacity = 2
  min_size         = 2
  max_size         = 4

  tag {
    key                 = "Name"
    value               = "asg-web"
    propagate_at_launch = true
  }

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
  }
}


# resource "aws_autoscaling_attachment" "awsome-ap2-web-as-att" {
#   autoscaling_group_name = aws_autoscaling_group.awsome-ap2-web-as.id
#   alb_target_group_arn   = aws_lb_target_group.awsome-ap2-web-tg.arn
# }
