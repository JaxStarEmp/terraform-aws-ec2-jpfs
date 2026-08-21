output "ec2_id" {
  description = "Id do EC2"
  value       = { for key, value in aws_instance.ec2 : key => value.id }
}

output "ec2_ip" {
  description = "Public IP da EC2"
  value       = { for key, value in aws_instance.ec2 : key => value.public_ip }
}

output "ec2_name" {
  description = "Nome da EC2"
  value       = { for key, value in aws_instance.ec2 : key => value.tags["Name"] }

}

output "ec2_ami" {
  description = "AMI da EC2"
  value       = { for key, value in data.aws_ami.ubuntu : key => value.id }
}

output "instances" {
  description = "Retornar as informações de todas as instâncias id,ami e ip em um único ouput"
  value = { for id, instance in aws_aws_instance.ec2 : id => {
    id  = instance.id
    ami = instance.ami
    ip  = instance.ip
  } }
}
