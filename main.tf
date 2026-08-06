resource "aws_security_group" "this" {
  name_prefix = "${var.name}-"
  description = "OpenVPN Access Server network access"
  vpc_id      = var.vpc_id

  tags = merge(local.common_tags, {
    Name = "${var.name}-sg"
  })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_vpc_security_group_ingress_rule" "vpn_tcp" {
  for_each = toset(var.vpn_client_cidrs)

  security_group_id = aws_security_group.this.id
  description       = "OpenVPN TCP tunnel and web portal"
  cidr_ipv4         = each.value
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "vpn_udp" {
  for_each = toset(var.vpn_client_cidrs)

  security_group_id = aws_security_group.this.id
  description       = "OpenVPN UDP tunnel"
  cidr_ipv4         = each.value
  from_port         = 1194
  to_port           = 1194
  ip_protocol       = "udp"
}

resource "aws_vpc_security_group_ingress_rule" "admin_ui" {
  for_each = var.enable_admin_port_943 ? toset(var.admin_cidrs) : toset([])

  security_group_id = aws_security_group.this.id
  description       = "OpenVPN Access Server admin and client UI"
  cidr_ipv4         = each.value
  from_port         = 943
  to_port           = 943
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "ssh" {
  for_each = var.enable_ssh ? toset(var.ssh_allowed_cidrs) : toset([])

  security_group_id = aws_security_group.this.id
  description       = "Restricted SSH administration"
  cidr_ipv4         = each.value
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "all" {
  security_group_id = aws_security_group.this.id
  description       = "Allow outbound access for updates and private network traffic"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_iam_role" "this" {
  name_prefix = "${var.name}-"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "this" {
  name_prefix = "${var.name}-"
  role        = aws_iam_role.this.name
  tags        = local.common_tags
}

resource "aws_eip" "this" {
  domain = "vpc"

  tags = merge(local.common_tags, {
    Name = "${var.name}-eip"
  })
}

resource "aws_instance" "this" {
  ami                         = local.selected_ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.this.id]
  iam_instance_profile        = aws_iam_instance_profile.this.name
  key_name                    = var.key_name
  associate_public_ip_address = var.associate_public_ip_for_bootstrap
  source_dest_check           = false
  monitoring                  = var.enable_detailed_monitoring
  disable_api_termination     = var.disable_api_termination

  user_data = templatefile("${path.module}/user_data.sh.tftpl", {
    server_address        = local.server_address
    additional_userdata   = var.additional_user_data
    additional_vpn_routes = var.additional_vpn_routes
  })

  user_data_replace_on_change = var.replace_instance_on_user_data_change

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "disabled"
  }

  root_block_device {
    volume_type           = "gp3"
    volume_size           = var.root_volume_size
    encrypted             = true
    delete_on_termination = true
  }

  tags = local.common_tags

  depends_on = [aws_iam_role_policy_attachment.ssm]
}

resource "aws_eip_association" "this" {
  allocation_id = aws_eip.this.id
  instance_id   = aws_instance.this.id
}

resource "aws_route53_record" "this" {
  count = var.route53_zone_id != null && var.hostname != null ? 1 : 0

  zone_id = var.route53_zone_id
  name    = var.hostname
  type    = "A"
  ttl     = var.route53_record_ttl
  records = [aws_eip.this.public_ip]
}
