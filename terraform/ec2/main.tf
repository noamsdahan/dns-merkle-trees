provider "aws" {
  region = "eu-north-1"
  profile = "terraform-personal"
}

# VPC
resource "aws_vpc" "dns_vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name = var.vpc_name
  }
}

# Public Subnet
resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.dns_vpc.id
  cidr_block        = var.public_subnet_cidr_block
  availability_zone = var.public_subnet_availability_zone

  tags = {
    Name = var.public_subnet_name
  }
}

# Private Subnet
resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.dns_vpc.id
  cidr_block        = var.private_subnet_cidr_block
  availability_zone = var.private_subnet_availability_zone

  tags = {
    Name = var.private_subnet_name
  }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.dns_vpc.id

  tags = {
    Name = "igw"
  }
}

# Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.dns_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public_route_table"
  }
}

# Route Table Association
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Security Group
resource "aws_security_group" "allow_ssh_and_dns" {
  name_prefix = "all"
  vpc_id      = aws_vpc.dns_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }
    ingress {
    from_port   = 53
    to_port     = 53
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_key_pair" "dns_ssh_keypair" {
  key_name   = "dns-ssh-keypair"
  public_key = file("dns_ssh_key.pub")
}

# Elastic IP for the primary DNS
resource "aws_eip" "primary_dns_eip" {
  vpc = true
}

# Elastic IP for the secondary DNS
resource "aws_eip" "secondary_dns_eip" {
  vpc = true
}

# Elastic IP for the bind resolver
resource "aws_eip" "bind_resolver_eip" {
  vpc = true
}

# Network interface for the primary DNS
resource "aws_network_interface" "primary_dns_ni" {
  subnet_id       = aws_subnet.public.id
  private_ips     = [var.primary_dns_private_ip]
  security_groups = [aws_security_group.allow_ssh_and_dns.id]
}

# Network interface for the secondary DNS
resource "aws_network_interface" "secondary_dns_ni" {
  subnet_id       = aws_subnet.public.id
  private_ips     = [var.secondary_dns_private_ip]
  security_groups = [aws_security_group.allow_ssh_and_dns.id]
}

# Network interface for the bind resolver
resource "aws_network_interface" "bind_resolver_ni" {
  subnet_id       = aws_subnet.private.id
  security_groups = [aws_security_group.allow_ssh_and_dns.id]
}

# Association of EIP with the primary DNS network interface
resource "aws_eip_association" "eip_assoc_primary_dns" {
  network_interface_id = aws_network_interface.primary_dns_ni.id
  allocation_id        = aws_eip.primary_dns_eip.id
}

# Association of EIP with the secondary DNS network interface
resource "aws_eip_association" "eip_assoc_secondary_dns" {
  network_interface_id = aws_network_interface.secondary_dns_ni.id
  allocation_id        = aws_eip.secondary_dns_eip.id
}

# Association of EIP with the bind resolver network interface
resource "aws_eip_association" "eip_assoc_bind_resolver" {
  network_interface_id = aws_network_interface.bind_resolver_ni.id
  allocation_id        = aws_eip.bind_resolver_eip.id
}

# Rest of your code...

# Primary DNS
resource "aws_instance" "primary_dns" {
  ami           = "ami-09e1162c87f73958b"
  instance_type = "t3.micro"
  key_name      = aws_key_pair.dns_ssh_keypair.key_name
  network_interface {
    network_interface_id = aws_network_interface.primary_dns_ni.id
    device_index         = 0
  }
  user_data = file("user_data_primary.sh")
  tags = {
    Name = "primary-dns"
  }
}

# Secondary DNS
resource "aws_instance" "secondary_dns" {
  ami           = "ami-09e1162c87f73958b"
  instance_type = "t3.micro"
  key_name      = aws_key_pair.dns_ssh_keypair.key_name
  network_interface {
    network_interface_id = aws_network_interface.secondary_dns_ni.id
    device_index         = 0
  }
  user_data = file("user_data_secondary.sh")
  tags = {
    Name = "secondary-dns"
  }
}

# BIND Recursive Resolver
resource "aws_instance" "bind_resolver" {
  ami           = "ami-09e1162c87f73958b"
  instance_type = "t3.micro"
  key_name      = aws_key_pair.dns_ssh_keypair.key_name
  network_interface {
    network_interface_id = aws_network_interface.bind_resolver_ni.id
    device_index         = 0
  }
  user_data = file("user_data_bind_resolver.sh")
  tags = {
    Name = "bind-resolver"
  }
}

# We need a NAT Gateway to allow the BIND Recursive Resolver to access the internet
# Create a NAT gateway
resource "aws_nat_gateway" "dns_nat_gateway" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public.id
  tags = {
    Name = "dns-nat-gateway"
  }
}

# Allocate an Elastic IP for the NAT gateway
resource "aws_eip" "nat" {
  vpc = true
}

# Define the route table for the private subnet
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.dns_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.dns_nat_gateway.id
  }
  tags = {
    Name = "private"
  }
}

# Associate the private subnet with the private route table
resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}

