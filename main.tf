resource "aws_instance" "ec2" {
  for_each      = var.instances
  ami           = data.aws_ami.ubuntu[each.key].id
  instance_type = each.value["ec2_type"]

  ebs_block_device {
    delete_on_termination = true
    device_name           = "/dev/sda1"
    volume_type           = "gp3"
    volume_size           = each.value["ec2_volume_size"]
    tags = {
      Name = "${each.value["ec2_type"]}-${var.env}"
    }
  }
  tags = {
    Name = "${each.value["ec2_name"]}-${var.env}"
  }
}

resource "aws_instance" "database" {
  for_each      = { for key, value in var.instances : key => value if value.create_database }
  count         = var.create_database && var.env == "prd" ? 1 : 0
  ami           = data.aws_ami.ubuntu.id
  instance_type = each.value["ec2_type"]
  tags = {
    Name = "${each.value["ec2_name"]}-db-${var.env}"
  }
}
