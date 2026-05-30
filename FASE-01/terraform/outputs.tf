output "vpc_id" {
  description = "ID da VPC provisionada"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "IDs das subnets públicas"
  value       = aws_subnet.public[*].id
}

output "alb_dns_name" {
  description = "DNS name do Application Load Balancer"
  value       = aws_lb.main.dns_name
}

output "alb_url" {
  description = "URL HTTP do Application Load Balancer"
  value       = "http://${aws_lb.main.dns_name}"
}

output "ec2_instance_ids" {
  description = "IDs das instâncias EC2"
  value       = aws_instance.app[*].id
}

output "ec2_public_ips" {
  description = "IPs públicos das instâncias EC2"
  value       = aws_instance.app[*].public_ip
}

output "security_group_alb_id" {
  description = "ID do security group do ALB"
  value       = aws_security_group.alb.id
}

output "security_group_app_id" {
  description = "ID do security group da aplicação"
  value       = aws_security_group.app.id
}
