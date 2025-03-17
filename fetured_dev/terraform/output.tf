output "public_ip" {
  value       = aws_instance.ec2_instance.public_ip
  description = "The public IP address of the EC2 instance"
}

output "ssh_key_file" {
  value       = local_file.private_ssh_key.filename
  description = "Local path of the SSH private key"
}

output "security_group_id" {
  value       = aws_security_group.instance_sg.id
  description = "Security Group ID assigned to the instance"
}

output "ssh_access_command" {
  value       = "ssh -i ${local_file.private_ssh_key.filename} ec2-user@${aws_instance.ec2_instance.public_ip}"
  description = "Command to SSH into the EC2 instance"
}
