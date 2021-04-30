#
# Notes
#

# k3s server instance
resource "aws_instance" "server" {
  ami           = data.aws_ami.default.id
  instance_type = var.aws_instance_type
  key_name      = aws_key_pair.default.id
  subnet_id     = data.aws_subnet.default.id
  depends_on    = [local_file.private_key_file]
  vpc_security_group_ids = [
    aws_security_group.ingress_sg.id,
    aws_security_group.ingress_client.id,
    aws_security_group.egress_all.id,
  ]
  tags = {
    Name  = format("%s-%s", var.cluster_name, "server"),
    Tag   = var.cluster_name,
    Owner = basename(data.aws_caller_identity.current.arn),
  }
  connection {
    type        = "ssh"
    user        = var.ami_instance_user
    private_key = file(var.private_key_path)
    host        = self.public_dns
  }
  root_block_device {
    volume_size = var.aws_root_block_size
  }
  # patch elastic max_map_count issue
  provisioner "remote-exec" {
    inline = [
      "sudo sh -c 'echo 'vm.max_map_count=262144' >> /etc/sysctl.d/vm-max_map_count.conf'",
      "sysctl -w vm.max_map_count=262144"
    ]
  }

  # install k3s server with k3sup
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = <<EOF
    k3sup install --host ${self.public_dns} \
      --user ${var.ami_instance_user} \
      --k3s-version ${var.k3s_version} \
      --ssh-key ${var.private_key_path} \
      --local-path ${var.kube_config_path} \
      --k3s-extra-args '--write-kubeconfig-mode ${var.k3s_kubeconfig_mode} ${var.k3s_extra_args}' \
      ${var.k3s_disable_extras ? "--no-extras" : ""}
    EOF
  }
  # wait for the node to exist and be ready after installation
  # this is easier on the server node, since kubectl works
  # we can just grab the hostname and check it against kubectl
  provisioner "remote-exec" {
    inline = [
      "until kubectl get no -o name | grep $(hostname); do sleep 1; done",
      "kubectl wait --for=condition=Ready node/$(hostname)"
    ]
  }
}

# k3s agent instance
resource "aws_instance" "agent" {
  ami           = data.aws_ami.default.id
  instance_type = var.aws_instance_type
  key_name      = aws_key_pair.default.id
  subnet_id     = data.aws_subnet.default.id
  count         = var.agent_count
  depends_on    = [aws_instance.server]
  vpc_security_group_ids = [
    aws_security_group.ingress_sg.id,
    aws_security_group.ingress_client.id,
    aws_security_group.egress_all.id,
  ]
  tags = {
    Name  = format("%s-%s", var.cluster_name, "agent"),
    Tag   = var.cluster_name,
    Owner = basename(data.aws_caller_identity.current.arn),
  }
  connection {
    type        = "ssh"
    user        = var.ami_instance_user
    private_key = file(var.private_key_path)
    host        = self.public_dns
  }
  root_block_device {
    volume_size = var.aws_root_block_size
  }
  # patch elastic max_map_count issue
  provisioner "remote-exec" {
    inline = [
      "sudo sh -c 'echo 'vm.max_map_count=262144' >> /etc/sysctl.d/vm-max_map_count.conf'",
      "sysctl -w vm.max_map_count=262144"
    ]
  }
  # install k3s server with k3sup
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = <<EOF
    k3sup join --host ${self.public_dns} \
      --user ${var.ami_instance_user} \
      --k3s-version ${var.k3s_version} \
      --ssh-key ${var.private_key_path} \
      --server-host ${aws_instance.server.public_dns}
    EOF
  }
  # wait for the node to exist and be ready after installation
  # TODO - This is a bit hacky, but...
  # it's the first way I could think to verify the agent nodes
  # considering they do not have kubectl access by default
  # which rules out remote-exec, but we can assume their hostnames
  # the default hostname (for ubuntu ec2) is 'ip-12-34-56-78'
  # with the dashed ip address being the intance's private ip
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    environment = { KUBECONFIG = var.kube_config_path }
    command     = <<EOF
    until kubectl get no -o name | grep 'ip-${replace(self.private_ip, ".", "-")}'; do sleep 1; done && \
      kubectl wait --for=condition=Ready 'node/ip-${replace(self.private_ip, ".", "-")}'
    EOF
  }
}