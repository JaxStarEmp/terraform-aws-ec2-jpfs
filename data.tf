data "aws_ami" "ubuntu" {
  for_each    = { for k, v in var.instances : k => v if v.ami_id == null }
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-*${each.value["ubuntu_version"]}*-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}
