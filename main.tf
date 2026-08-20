resource "aws_instance" "ec2" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.ec2_type

  ebs_block_device {
    delete_on_termination = true
    device_name           = "/dev/sda1"
    volume_type           = "gp3"
    volume_size           = var.ec2_volume_size
    tags = {
      Name = "${var.ec2_name}-${var.env}"
    }
  }
  tags = {
    Name = "${var.ec2_name}-${var.env}"
  }
}

resource "aws_instance" "database" {
  count         = var.create_database && var.env == "prd" ? 1 : 0
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.ec2_type
  tags = {
    Name = "${var.ec2_name}-db-${var.env}"
  }
}
