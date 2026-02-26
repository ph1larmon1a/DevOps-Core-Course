output "public_ipv4" {
  description = "Public IPv4 address of the devops instance"
  value       = aws_instance.devops.public_ip
}
