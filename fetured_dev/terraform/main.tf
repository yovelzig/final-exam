provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

# create SSH key
resource "tls_private_key" "generated_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "private_ssh_key" {
  content         = tls_private_key.generated_key.private_key_pem
  filename        = "${path.module}/${var.owner_name}_access_key.pem"
  file_permission = "0600"
}

# Key Pair AWS
resource "aws_key_pair" "ssh_key_pair" {
  key_name   = "${var.owner_name}-access-key"
  public_key = tls_private_key.generated_key.public_key_openssh
}

# Security Group EC2
resource "aws_security_group" "instance_sg" {
  name        = "${var.owner_name}-sg"
  description = "Security group for EC2 instance owned by ${var.owner_name}"
  vpc_id      = var.vpc_id

 
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

 
  ingress {
    from_port   = 5001
    to_port     = 5001
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

 
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name  = "${var.owner_name}-sg"
    Owner = var.owner_name
  }
}

# latest ami from amazon
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# public subnets from vpc
data "aws_subnets" "public_subnets" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
  
  filter {
    name   = "map-public-ip-on-launch"
    values = ["true"]
  }
}

#  EC2 Instance creation
resource "aws_instance" "ec2_instance" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.ssh_key_pair.key_name
  vpc_security_group_ids = [aws_security_group.instance_sg.id]

 
  subnet_id = tolist(data.aws_subnets.public_subnets.ids)[0]

  user_data = <<-EOF
              #!/bin/bash
              
              yum update -y

              
              amazon-linux-extras enable docker
              yum install -y docker
              systemctl start docker
              systemctl enable docker
              usermod -aG docker ec2-user

              # Docker Compose
              curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
              chmod +x /usr/local/bin/docker-compose
              ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
              EOF

  tags = {
    Name  = "${var.owner_name}-ec2-instance"
    Owner = var.owner_name
  }
}