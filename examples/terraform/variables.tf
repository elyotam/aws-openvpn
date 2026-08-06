variable "aws_region" {
  type        = string
  description = "AWS Region for the deployment."
  default     = "eu-west-1"
}

variable "name" {
  type        = string
  description = "Resource name prefix."
  default     = "customer-openvpn"
}

variable "vpc_id" {
  type        = string
  description = "Existing VPC ID."
}

variable "subnet_id" {
  type        = string
  description = "Existing public subnet ID."
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type."
  default     = "t3.small"
}

variable "hostname" {
  type        = string
  description = "Optional public hostname."
  default     = null
  nullable    = true
}

variable "route53_zone_id" {
  type        = string
  description = "Optional Route 53 hosted zone ID."
  default     = null
  nullable    = true
}

variable "vpn_client_cidrs" {
  type        = list(string)
  description = "CIDRs allowed to connect to the VPN ports."
  default     = ["0.0.0.0/0"]
}

variable "admin_cidrs" {
  type        = list(string)
  description = "Trusted administrator CIDRs for TCP 943."
  default     = []
}

variable "enable_ssh" {
  type        = bool
  description = "Enable inbound SSH."
  default     = false
}

variable "ssh_allowed_cidrs" {
  type        = list(string)
  description = "Trusted SSH CIDRs."
  default     = []
}

variable "key_name" {
  type        = string
  description = "Optional EC2 key pair."
  default     = null
  nullable    = true
}

variable "tags" {
  type        = map(string)
  description = "Additional resource tags."
  default = {
    Environment = "dev"
    Project     = "openvpn"
  }
}
