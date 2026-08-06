variable "company_name" {
  description = "Short lowercase company identifier used only for resource names and tags."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]{2,24}$", var.company_name))
    error_message = "company_name must contain 2-24 lowercase letters, numbers, or hyphens."
  }
}

variable "aws_region" {
  description = "AWS Region containing both non-production VPCs."
  type        = string
  default     = "eu-west-1"
}

variable "dev_vpc_id" {
  description = "Development VPC ID where OpenVPN Access Server is deployed."
  type        = string
}

variable "dev_vpc_cidr" {
  description = "Development VPC IPv4 CIDR."
  type        = string
}

variable "dev_public_subnet_id" {
  description = "Development public subnet ID used for OpenVPN Access Server."
  type        = string
}

variable "dev_route_table_ids" {
  description = "Development route table IDs that need a route to staging."
  type        = set(string)
}

variable "staging_vpc_id" {
  description = "Staging VPC ID connected to development."
  type        = string
}

variable "staging_vpc_cidr" {
  description = "Staging VPC IPv4 CIDR advertised to VPN clients."
  type        = string
}

variable "staging_route_table_ids" {
  description = "Staging route table IDs that need a return route to development."
  type        = set(string)
}

variable "admin_cidrs" {
  description = "Trusted administrator public IPv4 CIDRs allowed to access TCP 943."
  type        = list(string)
}

variable "vpn_client_cidrs" {
  description = "Source IPv4 CIDRs allowed to connect to the VPN service."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "instance_type" {
  description = "EC2 instance type for the development OpenVPN server."
  type        = string
  default     = "t3.small"
}

variable "hostname" {
  description = "Optional non-production VPN hostname."
  type        = string
  default     = null
  nullable    = true
}

variable "route53_zone_id" {
  description = "Optional Route 53 hosted zone ID for hostname."
  type        = string
  default     = null
  nullable    = true
}

variable "tags" {
  description = "Additional customer-owned tags. Do not put secrets in tags."
  type        = map(string)
  default     = {}
}
