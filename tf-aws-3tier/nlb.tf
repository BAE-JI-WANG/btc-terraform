# NLB
resource "aws_lb" "awsome-ap2-was-nlb" {
  name               = "was-nlb"
  internal           = true
  load_balancer_type = "network"

  subnets = [aws_subnet.awesome-ap-was-sub-2a.id, aws_subnet.awesome-ap-was-sub-2c.id]
  tags = {
    "Name" = "awesome-ap2-was-nlb"
  }
}

# module "awsome-ap2-was-nlb" {
#   source             = "terraform-aws-modules/alb/aws"
#   version            = "~> 6.0"
#   internal           = true
#   load_balancer_type = "network"
#   subnets            = [aws_subnet.awesome-ap-was-sub-2a.id, aws_subnet.awesome-ap-was-sub-2c.id]
#   tags = {
#     "Name" = "awesome-ap2-was-nlb"
#   }
# }

# Target Group
resource "aws_lb_target_group" "awsome-ap2-was-tg" {
  name_prefix = "wastg-"
  port        = 8009
  protocol    = "TCP"
  vpc_id      = aws_vpc.awesome-vpc.id

  lifecycle {
    create_before_destroy = true
  }
  tags = {
    "Name" = "awsome-ap2-was-tg"
  }
}

# resource "aws_lb_target_group_attachment" "awsome-ap2-was-tg-att" {
#   target_group_arn = aws_lb_target_group.awsome-ap2-was-tg.arn
#   target_id        = aws_autoscaling_group.awsome-ap2-was-as.id
#   port             = 8009
# }

# lb_listener
resource "aws_lb_listener" "awsome-ap2-was-nlb-listen" {
  load_balancer_arn = aws_lb.awsome-ap2-was-nlb.arn
  port              = 8009
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.awsome-ap2-was-tg.arn
  }
}

# Launch Configuration
resource "aws_launch_configuration" "awsome-ap2-was-conf" {
  name_prefix     = "awsome-ap2-was-"
  image_id        = var.was_ami
  instance_type   = "t2.micro"
  user_data       = file("was.sh")
  key_name        = var.was_key
  security_groups = [aws_security_group.awesome-ap2-was-sg.id]
  lifecycle {
    create_before_destroy = true
  }
}

# Auto Scaling group
resource "aws_autoscaling_group" "awsome-ap2-was-as" {
  name_prefix          = "awsome-ap2-was-as-"
  launch_configuration = aws_launch_configuration.awsome-ap2-was-conf.name
  vpc_zone_identifier  = [aws_subnet.awesome-ap-was-sub-2a.id, aws_subnet.awesome-ap-was-sub-2c.id]
  target_group_arns    = [aws_lb_target_group.awsome-ap2-was-tg.arn]
  health_check_type    = "ELB"
  desired_capacity     = 4
  min_size             = 4
  max_size             = 8

  tag {
    key                 = "Name"
    value               = "asg-was"
    propagate_at_launch = true
  }

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
  }
}

# resource "aws_autoscaling_attachment" "awsome-ap2-was-as-att" {
#   autoscaling_group_name = aws_autoscaling_group.awsome-ap2-was-as.id
#   lb_target_group_arn    = aws_lb.awsome-ap2-was-nlb.arn
# }