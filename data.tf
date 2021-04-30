# obtain the current aws caller identity
data "aws_caller_identity" "current" {}

# obtain client information
# (ip address, etc)
data "external" "client_info" {
  program = ["/bin/bash", "${path.module}/scripts/client_info.sh"]
}

# obtain vpc object from vpc id
data "aws_vpc" "default" {
  id = var.vpc_id
}

# obtain subnet object from vpc id
data "aws_subnet" "default" {
  id = var.subnet_id
}

# obtain a valid aws ami to use for deployment
data "aws_ami" "default" {
  owners      = var.ami_owner_id
  most_recent = true
  filter {
    name   = "name"
    values = var.ami_filter_name
  }
  filter {
    name   = "root-device-type"
    values = var.ami_root_device_type
  }
  filter {
    name   = "virtualization-type"
    values = var.ami_virtualization_type
  }
}