provider "aws" {
  region = var.aws_region
}

module "openvpn" {
  source = "../.."

  name          = var.name
  vpc_id        = var.vpc_id
  subnet_id     = var.subnet_id
  instance_type = var.instance_type

  hostname        = var.hostname
  route53_zone_id = var.route53_zone_id

  vpn_client_cidrs = var.vpn_client_cidrs
  admin_cidrs     = var.admin_cidrs

  enable_ssh       = var.enable_ssh
  ssh_allowed_cidrs = var.ssh_allowed_cidrs
  key_name         = var.key_name

  tags = var.tags
}
