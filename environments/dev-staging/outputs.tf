output "openvpn_public_ip" {
  description = "Elastic IP of the development OpenVPN Access Server."
  value       = module.openvpn_dev.elastic_ip
}

output "openvpn_admin_url" {
  description = "Administration URL for the development OpenVPN Access Server."
  value       = module.openvpn_dev.admin_url
}

output "dev_staging_peering_id" {
  description = "ID of the non-production VPC peering connection."
  value       = aws_vpc_peering_connection.dev_staging.id
}
