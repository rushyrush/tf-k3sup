terraform {
  required_version = ">= 0.14.8"
}

provider "aws" {
  region = var.aws_region
}