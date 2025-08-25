# Variables for main.tf
variable "aws_region" {
  default = "eu-north-1"
}

variable "aws_profile" {
  default = "terraform-personal"
}

# VPC
variable "vpc_cidr_block" {
  default = "10.0.0.0/16"
}

variable "vpc_name" {
  default = "dns_vpc"
}

# Public Subnet
variable "public_subnet_cidr_block" {
  default = "10.0.1.0/24"
}

variable "public_subnet_availability_zone" {
  default = "eu-north-1a"
}

variable "public_subnet_name" {
  default = "public_subnet"
}

# Private Subnet
variable "private_subnet_cidr_block" {
  default = "10.0.2.0/24"
}

variable "private_subnet_availability_zone" {
  default = "eu-north-1b"
}

variable "private_subnet_name" {
  default = "private_subnet"
}

# EC2 Instances
variable "primary_dns_private_ip" {
  default = "10.0.1.11"
}

variable "secondary_dns_private_ip" {
  default = "10.0.1.12"
}