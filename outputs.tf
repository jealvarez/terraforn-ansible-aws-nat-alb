output "lb_alb" {
  value       = aws_lb.alb.dns_name
  description = "application load balancer dns"
}
