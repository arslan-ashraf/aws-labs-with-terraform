# Application Load Balancer
resource "aws_lb" "application_load_balancer" {
  name               = "external-alb"
  internal           = false            # false means internet facing
  load_balancer_type = "application"

  security_groups = [
    aws_security_group.security_group_for_application_load_balancer.id
  ]

  subnets = [
    aws_subnet.public_subnet_1_for_application_load_balancer.id,
    aws_subnet.public_subnet_2_for_application_load_balancer.id
  ]
  
  # enable_deletion_protection = false 

}

resource "aws_lb_target_group" "web_servers_target_group" {
  name     = "web-servers-target-group"
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

# listens to http requests and then forwards them to the load balancer's 
# target group, see the field target_group_arn
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.application_load_balancer.arn
  port              = "80"
  protocol          = "HTTP"


  default_action {
    type             = "forward"        # redirect to https is better
    target_group_arn = aws_lb_target_group.web_servers_target_group.arn
  }
}

data "aws_acm_certificate" "acm_tls_certificate" {
  domain = var.custom_domain
}

resource "aws_lb_listener" "https_listener" {
  load_balancer_arn = aws_lb.application_load_balancer.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = data.aws_acm_certificate.acm_tls_certificate.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_servers_target_group.arn
  }
}

# Target Group Attachments
resource "aws_lb_target_group_attachment" "web_server_1_attachment" {
  target_group_arn = aws_lb_target_group.web_servers_target_group.arn
  target_id        = aws_instance.web_server_1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "web_server_2_attachment" {
  target_group_arn = aws_lb_target_group.web_servers_target_group.arn
  target_id        = aws_instance.web_server_2.id
  port             = 80
}

# Output URL
output "alb_dns_name" {
  value       = aws_lb.application_load_balancer.dns_name
  description = "The public URL of the application load balancer"
}