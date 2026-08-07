provider "aws" {
  region = var.aws_region
}

locals {
  common_tags = merge(var.tags, {
    Company          = var.company_name
    ManagedBy        = "Terraform"
    EnvironmentScope = "dev-staging"
  })
}

resource "aws_vpc_peering_connection" "dev_staging" {
  vpc_id      = var.dev_vpc_id
  peer_vpc_id = var.staging_vpc_id
  auto_accept = true

  requester {
    allow_remote_vpc_dns_resolution = true
  }

  accepter {
    allow_remote_vpc_dns_resolution = true
  }

  tags = merge(local.common_tags, {
    Name = "${var.company_name}-dev-staging"
  })

  lifecycle {
    precondition {
      condition     = var.dev_vpc_id != var.staging_vpc_id
      error_message = "dev_vpc_id and staging_vpc_id must be different."
    }
  }
}

resource "aws_route" "dev_to_staging" {
  for_each = var.dev_route_table_ids

  route_table_id            = each.value
  destination_cidr_block    = var.staging_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.dev_staging.id
}

resource "aws_route" "staging_to_dev" {
  for_each = var.staging_route_table_ids

  route_table_id            = each.value
  destination_cidr_block    = var.dev_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.dev_staging.id
}

module "openvpn_dev" {
  source = "../.."

  name          = "${var.company_name}-openvpn-dev"
  vpc_id        = var.dev_vpc_id
  subnet_id     = var.dev_public_subnet_id
  instance_type = var.instance_type

  hostname        = var.hostname
  route53_zone_id = var.route53_zone_id

  vpn_client_cidrs = var.vpn_client_cidrs
  admin_cidrs      = var.admin_cidrs
  additional_vpn_routes = [
    var.dev_vpc_cidr,
    var.staging_vpc_cidr,
  ]

  enable_ssh = false

  tags = merge(local.common_tags, {
    Environment = "dev"
  })
}
