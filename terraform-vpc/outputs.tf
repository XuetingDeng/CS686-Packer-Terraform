output "bastion_public_ip" {
  value = aws_instance.bastion.public_ip
}

output "private_instance_ids" {
  value = [for i in aws_instance.private_ec2 : i.id]
}
