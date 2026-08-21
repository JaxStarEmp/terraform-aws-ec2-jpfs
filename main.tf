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

  dynamic "ebs_block_device" {
    for_each = each.value.extra_volumes
    iterator = vol
    content {
      delete_on_termination = vol.value.delete_on_termination
      device_name           = vol.value.device_name
      volume_size           = vol.value.volume_size
      tags = {
        Name = "volume-${element(split("/", vol.value.device_name), -1)}-${var.env}"
      }
    }

  }

  tags = {
    Name = "${each.value["ec2_name"]}-${var.env}"
  }
}

resource "aws_instance" "database" {
  for_each      = { for key, value in var.instances : key => value if value.create_database }
  ami           = data.aws_ami.ubuntu[each.key].id
  instance_type = each.value["ec2_type"]
  tags = {
    Name = "${each.value["ec2_name"]}-db-${var.env}"
  }
}
