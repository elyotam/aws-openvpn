data "aws_ssm_parameter" "ubuntu_ami" {
  count = var.ami_id == null ? 1 : 0
  name  = var.ubuntu_ami_ssm_parameter
}
