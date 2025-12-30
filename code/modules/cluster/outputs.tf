output "alb_hostname" {
  value = aws_alb.main.dns_name
  description = "ALB dns"
}

output "application_url" {
  value = "${aws_alb.main.dns_name}/front/dashboard"
  description = "URL to access the application"
}