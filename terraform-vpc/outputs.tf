# ----------------------------
# Output all ip address
# ----------------------------
output "ubuntu_private_ips" {
  value = [for i in aws_instance.ubuntu_instances : i.private_ip]
}

output "amazon_private_ips" {
  value = [for i in aws_instance.amazon_instances : i.private_ip]
}

output "controller_private_ip" {
  value = aws_instance.ansible_controller.private_ip
}
