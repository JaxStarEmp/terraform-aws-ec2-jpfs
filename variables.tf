variable "env" {
  type        = string
  description = "Ambiente de deploy"
}

variable "instances" {
  type = map(object({
    ec2_name        = string
    ec2_type        = optional(string, "t3.micro")
    ec2_volume_size = optional(number, 10)
    ubuntu_version  = optional(string, "24.04")
    create_database = optional(bool, false)
  }))
  description = "Mapa de objeto das informações da instâncias, como nome,tipo, volume, versão do ubuntu e se deve criar database"
}
