resource "aws_security_group" "devops-sg" {
  name        = "amazon-Security-Group"
  description = "Open required ports"

  # ✅ FIXED (default VPC)
  vpc_id = data.aws_vpc.default.id

  ingress = [
    for port in [22, 80, 443, 9000, 3000, 9090, 8080] : {
      description      = "Allow traffic"
      from_port        = port
      to_port          = port
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    }
  ]

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "DevOps-sg"
  }
}