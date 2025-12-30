output "alb_subnet_az_alfa" {
  value = aws_subnet.alb_subnet_az_1_alfa.id
}

output "alb_subnet_az_beta" {
  value = aws_subnet.alb_subnet_az_1_beta.id
}

output "front_subnet_id" {
  value = aws_subnet.front_subnet.id
}

output "back_subnet_id" {
  value = aws_subnet.back_subnet.id
}

output "vpc_id" {
  value = aws_vpc.main.id
}

