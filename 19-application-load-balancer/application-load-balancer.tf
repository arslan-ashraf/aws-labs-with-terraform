# 7. Application Load Balancer Architecture
resource "aws_lb" "external_application_load_balancer" {
  name               = "external_application_load_balancer"
  internal           = false
  load_balancer_type = "application"

  security_groups    = [
    aws_security_group.security_group_for_application_load_balancer.id
  ]

  subnets            = [
    aws_subnet.public_subnet_1_for_application_load_balancer.id, 
    aws_subnet.public_subnet_2_for_application_load_balancer.id
  ]
  
}

resource "aws_lb_target_group" "web_servers_target_group" {
  name     = "web_servers_target_group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.example_vpc.id

  health_check {
    path                = "/"
    port                = "80"
    protocol            = "HTTP"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.external_application_load_balancer.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }
}

# 8. Target Group Attachments
resource "aws_lb_target_group_attachment" "web_1" {
  target_group_arn = aws_lb_target_group.web.arn
  target_id        = aws_instance.web_1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "web_2" {
  target_group_arn = aws_lb_target_group.web.arn
  target_id        = aws_instance.web_2.id
  port             = 80
}

# 9. Output URL
output "alb_dns_name" {
  value       = aws_lb.external_application_load_balancer.dns_name
  description = "The public URL of the application load balancer"
}