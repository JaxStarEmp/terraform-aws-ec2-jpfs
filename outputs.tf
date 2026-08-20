output "ec2_id" {
  description = "Id do EC2"
  value       = { for key, value in var.aws_instance.ec2 : key => value.id }
}

output "ec2_ip" {
  description = "Public IP da EC2"
  value       = { for key, value in var.aws_instance.ec2 : key => value.public_ip }
}

output "ec2_name" {
  description = "Nome da EC2"
  value       = { for key, value in var.aws_instance.ec2 : key => value.tags["Name"] }

}

output "ec2_ami" {
  description = "AMI da EC2"
  value       = { for key, value in data.aws_ami.ubuntu : key => value.id }
}

