variable "aws_region" {
  description = "Região AWS onde os recursos serão provisionados"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Nome do projeto utilizado como prefixo nos recursos"
  type        = string
  default     = "desafio-iac"
}

variable "environment" {
  description = "Ambiente de deploy (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "CIDR block da VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "instance_type" {
  description = "Tipo de instância EC2 para a aplicação"
  type        = string
  default     = "t3.micro"
}

variable "app_port" {
  description = "Porta HTTP da aplicação Spring Boot"
  type        = number
  default     = 8080
}

variable "instance_count" {
  description = "Número de instâncias EC2"
  type        = number
  default     = 2
}

variable "key_name" {
  description = "Nome do par de chaves EC2 para acesso SSH"
  type        = string
  default     = ""
}
