output "alb_hostname" {
  value = aws_alb.main.dns_name
  description = "ALB dns"
}
