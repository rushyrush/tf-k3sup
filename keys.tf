resource "tls_private_key" "default" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "default" {
  public_key = tls_private_key.default.public_key_openssh
  tags = {
    Name  = format("%s-%s", var.cluster_name, "default"),
    Tag   = var.cluster_name,
    Owner = basename(data.aws_caller_identity.current.arn),
  }
}