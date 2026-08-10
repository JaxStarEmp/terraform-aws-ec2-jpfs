variable "ec2_name" {
  description = "Nome da EC2"
}

variable "ec2_type" {
  description = "Tipo de EC2"
  default     = "t3.micro"
}

variable "ubuntu_version" {
  description = "Versão do Ubuntu"
  default     = "24.04"
}

variable "env" {
  description = "Ambiente de deploy"
}