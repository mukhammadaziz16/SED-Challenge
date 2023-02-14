# target group
resource "aws_alb_target_group" "target-group" {
  health_check {
    interval            = 10
    path                = "/"
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
  }

  name        = "team1-tg"
  port        = 80
  protocol    = "HTTP"
  #target_type = "alb"
  vpc_id      = aws_default_vpc.default.id
}

# Application Load Balancer
resource "aws_alb" "application-lb" {
  name               = "team1-alb"
  internal           = false
  ip_address_type    = "ipv4"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.web-server.id]
  subnets            = data.aws_subnet_ids.subnet.ids
}

# Creating Listener
resource "aws_alb_listener" "alb-listener" {
  load_balancer_arn = aws_alb.application-lb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    target_group_arn = aws_alb_target_group.target-group.arn
    type             = "forward"
  }
}

# Create a new ALB Target Group attachment
resource "aws_autoscaling_attachment" "asg_attachment" {
  autoscaling_group_name = module.asg.autoscaling_group_id
  lb_target_group_arn    = aws_alb_target_group.target-group.arn
}