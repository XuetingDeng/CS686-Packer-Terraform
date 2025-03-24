packer {
  required_plugins {
    amazon = {
      source = "github.com/hashicorp/amazon"
      version = "~> 1.0"
    }
  }
}

variable "aws_region" {
  default = "us-east-1"
}

source "amazon-ebs" "amazon-linux-docker" {
  region                  = var.aws_region
  source_ami_filter {
    filters = {
      name                = "amzn2-ami-hvm-*-x86_64-gp2"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    owners      = ["137112412989"]
    most_recent = true
  }
  instance_type           = "t2.micro"
  ssh_username            = "ec2-user"
  ami_name                = "custom-amazon-linux-docker-{{timestamp}}"

  ssh_keypair_name        = "packer-key"
  ssh_private_key_file    = "~/.ssh/packer_rsa"
}

build {
  name    = "amazon-linux-docker"
  sources = ["source.amazon-ebs.amazon-linux-docker"]

  provisioner "shell" {
    inline = [
      "sudo yum update -y",
      "sudo amazon-linux-extras install docker -y",
      "sudo service docker start",
      "sudo usermod -aG docker ec2-user"
    ]
  }
}
