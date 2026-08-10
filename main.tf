resource "aws_instance" "ec2" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.ec2_type
  tags = {
    Name = "${var.ec2_name}-${var.env}"
  }
}
