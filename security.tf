# allow all ingress from this security group
resource "aws_security_group" "ingress_sg" {
  vpc_id = data.aws_vpc.default.id
  ingress {
    self      = true
    from_port = 0
    to_port   = 0
    protocol  = "-1"
  }
  tags = {
    Name  = format("%s-%s", var.cluster_name, "ingress_sg"),
    Tag   = var.cluster_name,
    Owner = basename(data.aws_caller_identity.current.arn),
  }
}

# allow all ingress from the client machine
resource "aws_security_group" "ingress_client" {
  vpc_id = data.aws_vpc.default.id
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [format("%s/%s", data.external.client_info.result["ip"], 32)]
  }
  tags = {
    Name  = format("%s-%s", var.cluster_name, "ingress_client"),
    Tag   = var.cluster_name,
    Owner = basename(data.aws_caller_identity.current.arn),
  }
}

# allow all egress
resource "aws_security_group" "egress_all" {
  vpc_id = data.aws_vpc.default.id
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name  = format("%s-%s", var.cluster_name, "egress_all"),
    Tag   = var.cluster_name,
    Owner = basename(data.aws_caller_identity.current.arn),
  }
}