terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-west-1"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

resource "tls_private_key" "key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = var.ssh_key_name
  public_key = tls_private_key.key.public_key_openssh

  provisioner "local-exec" {
    command = <<-EOT
      echo '${tls_private_key.key.private_key_pem}' > ./'${var.ssh_key_name}'.pem
      chmod 400 ./'${var.ssh_key_name}'.pem
    EOT
  }
}

data "cloudinit_config" "lab_init" {
  part {
    content_type = "text/cloud-config"
    content = yamlencode({
      write_files = [
        {
          encoding    = "b64"
          content     = filebase64("${path.root}/docker-compose.yml")
          path        = "/home/ubuntu/docker-compose.yml"
          owner       = "root:root"
          permissions = "0777"
        }
      ]
    })
  }

  part {
    content_type = "text/x-shellscript"
    content      = file("${path.root}/init_script.sh")
  }
}

resource "aws_instance" "topic-2-lab" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.ec2_lab_instance_type
  key_name                    = aws_key_pair.generated_key.key_name
  vpc_security_group_ids      = [aws_security_group.lab.id]
  subnet_id                   = aws_subnet.lab_public_subnet.id
  user_data                   = data.cloudinit_config.lab_init.rendered
  associate_public_ip_address = "true"

  tags = {
    Name = "devsecops-2"
  }
}