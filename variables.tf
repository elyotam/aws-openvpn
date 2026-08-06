variable "name" {
  description = "Name prefix used for the OpenVPN resources."
  type        = string
  default     = "openvpn-as"

  validation {
    condition     = length(trimspace(var.name)) >= 3
    error_message = "name must contain at least three characters."
  }
}

variable "vpc_id" {
  description = "VPC ID where the OpenVPN instance will run."
  type        = string
}

variable "subnet_id" {
  description = "Public subnet ID. The subnet must have a route to an Internet Gateway."
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type. t3.small is a practical starting point for small deployments."
  type        = string
  default     = "t3.small"
}

variable "ami_id" {
  description = "Optional AMI ID override. When null, the latest Canonical Ubuntu 24.04 AMD64 AMI is read from the public SSM parameter."
  type        = string
  default     = null
  nullable    = true
}

variable "ubuntu_ami_ssm_parameter" {
  description = "Canonical public SSM parameter containing the Ubuntu AMI ID."
  type        = string
  default     = "/aws/service/canonical/ubuntu/server/noble/stable/current/amd64/hvm/ebs-gp3/ami-id"
}

variable "hostname" {
  description = "Optional public hostname such as vpn.example.com. When null, Access Server uses the allocated Elastic IP."
  type        = string
  default     = null
  nullable    = true

  validation {
    condition     = var.hostname == null || can(regex("^[A-Za-z0-9.-]+$", var.hostname))
    error_message = "hostname must be null or a valid DNS hostname without a protocol prefix."
  }
}

variable "route53_zone_id" {
  description = "Optional Route 53 hosted zone ID. When supplied together with hostname, the module creates an A record."
  type        = string
  default     = null
  nullable    = true

  validation {
    condition     = var.route53_zone_id == null || var.hostname != null
    error_message = "hostname must be set when route53_zone_id is provided."
  }
}

variable "route53_record_ttl" {
  description = "TTL for the optional Route 53 A record."
  type        = number
  default     = 300
}

variable "vpn_client_cidrs" {
  description = "IPv4 CIDRs allowed to reach TCP 443 and UDP 1194. Public remote-access VPNs commonly use 0.0.0.0/0."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "admin_cidrs" {
  description = "IPv4 CIDRs allowed to reach TCP 943. Keep this limited to trusted administrator addresses."
  type        = list(string)
  default     = []
}

variable "enable_admin_port_943" {
  description = "Whether to create TCP 943 rules for admin_cidrs."
  type        = bool
  default     = true
}

variable "enable_ssh" {
  description = "Whether to allow inbound SSH. SSM Session Manager is enabled and preferred."
  type        = bool
  default     = false
}

variable "ssh_allowed_cidrs" {
  description = "IPv4 CIDRs allowed to reach SSH when enable_ssh is true."
  type        = list(string)
  default     = []

  validation {
    condition     = !var.enable_ssh || length(var.ssh_allowed_cidrs) > 0
    error_message = "ssh_allowed_cidrs must contain at least one CIDR when enable_ssh is true."
  }
}

variable "key_name" {
  description = "Optional EC2 key pair name. It is normally unnecessary when using SSM Session Manager."
  type        = string
  default     = null
  nullable    = true
}

variable "associate_public_ip_for_bootstrap" {
  description = "Temporarily requests a public IPv4 address at launch so cloud-init can install packages before the EIP association completes."
  type        = bool
  default     = true
}

variable "root_volume_size" {
  description = "Encrypted gp3 root volume size in GiB."
  type        = number
  default     = 20

  validation {
    condition     = var.root_volume_size >= 10
    error_message = "root_volume_size must be at least 10 GiB."
  }
}

variable "enable_detailed_monitoring" {
  description = "Enable EC2 detailed monitoring. This can create additional AWS charges."
  type        = bool
  default     = false
}

variable "disable_api_termination" {
  description = "Enable EC2 termination protection."
  type        = bool
  default     = false
}

variable "replace_instance_on_user_data_change" {
  description = "Replace the EC2 instance when user_data changes. Keep false for safer upgrades; rebuild deliberately when required."
  type        = bool
  default     = false
}

variable "additional_user_data" {
  description = "Optional shell commands appended to the bootstrap script. Never place secrets here because user_data is stored in Terraform state."
  type        = string
  default     = ""
}

variable "tags" {
  description = "Additional tags applied to created resources."
  type        = map(string)
  default     = {}
}
