output "custom_domain" {
  value = data.aws_route53_zone.custom_domain
}

output "alb_dns_name" {
  value       = aws_lb.application_load_balancer.dns_name
  description = "The public URL of the application load balancer"
}