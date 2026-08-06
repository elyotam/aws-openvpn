terraform {
  # For production, point to an immutable release tag:
  # source = "git::https://github.com/elyotam/aws-openvpn.git?ref=v1.0.0"
  source = "../.."
}

inputs = {
  name          = "customer-openvpn"
  vpc_id        = "vpc-REPLACE_ME"
  subnet_id     = "subnet-REPLACE_ME"
  instance_type = "t3.small"

  hostname        = null
  route53_zone_id = null

  vpn_client_cidrs = ["0.0.0.0/0"]
  admin_cidrs      = ["203.0.113.10/32"]

  enable_ssh        = false
  ssh_allowed_cidrs = []
  key_name          = null

  tags = {
    Customer    = "replace-me"
    Environment = "production"
    ManagedBy   = "Terragrunt"
  }
}
