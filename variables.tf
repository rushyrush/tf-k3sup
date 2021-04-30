#
# required
#

variable "aws_region" {
  description = "AWS region to spawn resources in"
  type        = string
}

variable "vpc_id" {
  description = "VPC to spawn resources in (must correspond with subnet_id, DNS must be enabled)"
  type        = string
}

variable "subnet_id" {
  description = "Subnet to spawn resources in (must correspond with vpc_id)"
  type        = string
}

variable "kube_config_path" {
  description = "Local path of kubernetes config file to create"
  type        = string
}

variable "private_key_path" {
  description = "Local path to the SSH private key to create"
  type        = string
}

#
# k3s
#

variable "k3s_version" {
  description = "Version of k3s to use when installing"
  default     = "v1.21.0+k3s1"
  type        = string
}

variable "k3s_extra_args" {
  description = "Extra arguments to pass when installing k3s"
  default     = "--disable=traefik --disable=metrics-server"
  type        = string
}

variable "agent_count" {
  description = "Number of k3s agents to spawn and join to the cluster"
  default     = 3
  type        = number
}

variable "k3s_disable_extras" {
  description = "Whether or not to disable k3s extra components"
  default     = true
  type        = bool
}

variable "k3s_kubeconfig_mode" {
  description = "Kubeconfig file permissions for the k3s server"
  default     = 644
  type        = number
}

#
# aws
#

variable "cluster_name" {
  description = "Desired tag name to use for AWS resources"
  default     = "tf-k3sup"
  type        = string
}

variable "aws_instance_type" {
  description = "Desired AWS instance type"
  default     = "t2.medium"
  type        = string
}

variable "aws_root_block_size" {
  description = "Desired AWS instance root block size"
  default     = 20
  type        = number
}

#
# ami
#

variable "ami_owner_id" {
  description = "Owner ID for use in the AMI filter (default: Canonical for US GovCloud)"
  default     = ["513442679011"]
  type        = list(string)
}

variable "ami_filter_name" {
  description = "Name to filter when picking an AMI (default: Ubuntu Focal 20.04)"
  default     = ["ubuntu/images/*ubuntu-focal-20.04-amd64-server-*"]
  type        = list(string)
}

variable "ami_root_device_type" {
  description = "AMI root device type to filter on"
  default     = ["ebs"]
  type        = list(string)
}

variable "ami_virtualization_type" {
  description = "AMI virtualization type to filter on"
  default     = ["hvm"]
  type        = list(string)
}

variable "ami_instance_user" {
  description = "Default AWS instance username"
  default     = "ubuntu"
  type        = string
}