output "instance_id" {
  description = "OpenVPN Access Server EC2 instance ID."
  value       = aws_instance.this.id
}

output "private_ip" {
  description = "Private IPv4 address of the EC2 instance."
  value       = aws_instance.this.private_ip
}

output "elastic_ip" {
  description = "Stable public Elastic IP address."
  value       = aws_eip.this.public_ip
}

output "server_address" {
  description = "Hostname or Elastic IP configured as the Access Server address."
  value       = local.server_address
}

output "admin_url" {
  description = "OpenVPN Access Server administration URL."
  value       = "https://${local.server_address}/admin/"
}

output "client_url" {
  description = "OpenVPN Access Server client portal URL."
  value       = "https://${local.server_address}/"
}

output "security_group_id" {
  description = "Security group attached to the OpenVPN instance."
  value       = aws_security_group.this.id
}

output "iam_role_name" {
  description = "IAM role attached to the instance."
  value       = aws_iam_role.this.name
}

output "ssm_session_command" {
  description = "AWS CLI command for opening an SSM Session Manager shell."
  value       = "aws ssm start-session --target ${aws_instance.this.id}"
}
