resource "aws_instance" "web" {
  ami           = "ami-0ec10929233384c7f"
  instance_type = "t3.medium"

subnet_id = data.aws_subnets.eks_subnets.ids[0]

  associate_public_ip_address = true

  key_name               = "vijay-kumar"
  vpc_security_group_ids = [aws_security_group.devops-sg.id]

  user_data = file("installation.sh")

  tags = {
    Name = "Amazon-vijay-kumar"
  }

  root_block_device {
    volume_size = 30
  }
}