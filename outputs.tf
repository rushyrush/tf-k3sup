#
# ip space
#

output "server_ip" {
  value = aws_instance.server.public_ip
}

output "agent_ip" {
  value = aws_instance.agent.*.public_ip
}

# ip space
#

output "server_dns" {
  value = aws_instance.server.public_dns
}

output "agent_dns" {
  value = aws_instance.agent.*.public_dns
}

#
# files
#

output "kube_config_path" {
  value = abspath(var.kube_config_path)
}

output "private_key_path" {
  value = abspath(var.private_key_path)
}

#
# client_info data
#

output "client_info_ip" {
  value = data.external.client_info.result["ip"]
}

#
# security groups
#

output "sg_ingress_sg_id" {
  value = aws_security_group.ingress_sg.id
}

output "sg_ingress_client_id" {
  value = aws_security_group.ingress_client.id
}

output "sg_egress_all_id" {
  value = aws_security_group.egress_all.id
}