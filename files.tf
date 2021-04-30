# ssh key file resource
resource "local_file" "private_key_file" {
  content         = tls_private_key.default.private_key_pem
  filename        = var.private_key_path
  file_permission = "0600"
}

# kubeconfig file resource
# used for destruction purposes
resource "null_resource" "kubeconfig_file" {
  # wait for these to be created first
  depends_on = [aws_instance.server]
  # triggers for destroy provisioners
  triggers = {
    kube_config_path = var.kube_config_path
  }
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = <<EOF
    rm -f ${self.triggers.kube_config_path}
    EOF
    when        = destroy
  }
}