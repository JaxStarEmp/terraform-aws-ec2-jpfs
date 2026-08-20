variable "ec2_name" {
  description = "Nome da EC2"
}

variable "ec2_type" {
  description = "Tipo de EC2"
  default     = "t3.micro"
}

variable "ec2_volume_size" {
  description = "Tamanho do volume da EC2"
  default     = 10
}

variable "ubuntu_version" {
  description = "Versão do Ubuntu"
  default     = "24.04"
}

variable "env" {
  description = "Ambiente de deploy"
}

variable "create_database" {
  description = "Feature Flag de criação da database instance"
  default = true
}