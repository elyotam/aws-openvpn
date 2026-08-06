locals {
  selected_ami_id = var.ami_id != null ? var.ami_id : data.aws_ssm_parameter.ubuntu_ami[0].value
  server_address  = var.hostname != null ? var.hostname : aws_eip.this.public_ip

  common_tags = merge(
    {
      Name      = var.name
      ManagedBy = "Terraform"
      Component = "OpenVPN-Access-Server"
    },
    var.tags
  )
}
