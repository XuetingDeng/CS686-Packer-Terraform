provider "aws" {
  region = "us-east-1"
}

module "vpc" {
  source              = "./modules/vpc"
  name                = "project"
  vpc_cidr            = "10.0.0.0/16"
  public_subnet_cidr  = "10.0.1.0/24"
  private_subnet_cidr = "10.0.2.0/24"
  az                  = "us-east-1a"
}

# ----------------------------
# Security Groups
# ----------------------------

resource "aws_security_group" "bastion_sg" {
  name        = "bastion-sg"
  description = "Allow SSH from my IP"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "private_sg" {
  name        = "private-sg"
  description = "Allow all internal traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ----------------------------
# Bastion Host (no change)
# ----------------------------

resource "aws_instance" "bastion" {
  ami                         = var.ami_id
  instance_type               = "t2.micro"
  subnet_id                   = module.vpc.public_subnet_id
  key_name                    = "packer-key"
  vpc_security_group_ids      = [aws_security_group.bastion_sg.id]
  associate_public_ip_address = true
  tags = {
    Name = "BastionHost"
  }
}

# ----------------------------
# AMI: Ubuntu 22.04 LTS
# ----------------------------

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# ----------------------------
# 3 Ubuntu Instances
# ----------------------------

resource "aws_instance" "ubuntu_instances" {
  count                       = 3
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t2.micro"
  subnet_id                   = module.vpc.private_subnet_id
  key_name                    = "packer-key"
  vpc_security_group_ids      = [aws_security_group.private_sg.id]
  associate_public_ip_address = false
  tags = {
    Name = "Ubuntu-${count.index + 1}"
    OS   = "ubuntu"
  }
}

# ----------------------------
# 3 Amazon Linux Instances (your custom AMI)
# ----------------------------

resource "aws_instance" "amazon_instances" {
  count                       = 3
  ami                         = var.ami_id
  instance_type               = "t2.micro"
  subnet_id                   = module.vpc.private_subnet_id
  key_name                    = "packer-key"
  vpc_security_group_ids      = [aws_security_group.private_sg.id]
  associate_public_ip_address = false
  tags = {
    Name = "Amazon-${count.index + 1}"
    OS   = "amazon"
  }
}

# ----------------------------
# Ansible Controller (Ubuntu)
# ----------------------------

resource "aws_instance" "ansible_controller" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t2.micro"
  subnet_id                   = module.vpc.private_subnet_id
  key_name                    = "packer-key"
  vpc_security_group_ids      = [aws_security_group.private_sg.id]
  associate_public_ip_address = false
  tags = {
    Name = "Ansible-Controller"
    Role = "controller"
  }
}