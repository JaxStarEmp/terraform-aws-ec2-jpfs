module "ec2-jpfs" {
  source = "../.."

  env = "dev"
  instances = {
    app = {
      ec2_name        = "aplicacao"
      ec2_type        = "t3.micro"
      ec2_volume_size = 30
      ubuntu_version  = "24.04"
      create_database = true
      extra_volumes = [
        { delete_on_termination = true, device_name = "/dev/sdb", volume_size = 30 },
        { delete_on_termination = true, device_name = "/dev/sdc", volume_size = 20 }
      ]
    }
    backend = {
      ec2_name        = "backend"
      ec2_type        = "t3.micro"
      ec2_volume_size = 20
      ubuntu_version  = "24.04"
      create_database = false
    }
  }
}