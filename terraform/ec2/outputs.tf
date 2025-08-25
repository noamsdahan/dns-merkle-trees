
# The public IP address of the primary DNS server
output "primary_dns_public_ip" {
  value = aws_instance.primary_dns.public_ip
}

# The private IP address of the primary DNS server
output "primary_dns_private_ip" {
  value = aws_instance.primary_dns.private_ip
}

# The public IP address of the secondary DNS server 
output "secondary_dns_public_ip" {
  value = aws_instance.secondary_dns.public_ip
}

# The private IP address of the secondary DNS server
output "secondary_dns_private_ip" {
  value = aws_instance.secondary_dns.private_ip
}

# The public IP address of the BIND recursive resolver
output "bind_resolver_public_ip" {
  value = aws_instance.bind_resolver.public_ip
}

# The private IP address of the BIND recursive resolver
output "bind_resolver_private_ip" {
  value = aws_instance.bind_resolver.private_ip
}
