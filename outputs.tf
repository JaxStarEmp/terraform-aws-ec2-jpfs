output "ec2_id" {
  description = "Id do EC2"
  value       = aws_instance.ec2.id
}

output "ec2_ip" {
  description = "Public IP da EC2"
  value       = aws_instance.ec2.public_ip
}

output "ec2_name" {
  description = "Nome da EC2"
  value       = aws_instance.ec2.tags["Name"]

}

output "ec2_ami" {
  description = "AMI da EC2"
  value       = data.aws_ami.ubuntu.id
}