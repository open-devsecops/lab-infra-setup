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
      rm ./'${var.ssh_key_name}'.pem 2> /dev/null
      echo '${tls_private_key.key.private_key_pem}' > ./'${var.ssh_key_name}'.pem
      chmod 400 ./'${var.ssh_key_name}'.pem
    EOT
  }
}

resource "aws_instance" "topic-2-lab" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.ec2_lab_instance_type
  key_name                    = aws_key_pair.generated_key.key_name
  vpc_security_group_ids      = [aws_security_group.lab.id]
  subnet_id                   = aws_subnet.lab_public_subnet.id
  iam_instance_profile        = aws_iam_instance_profile.ec2_role_profile.name
  
  user_data = templatefile("cloud_init.yml.tftpl", {
    wg_port                      = var.wg_port,
    public_iface                 = var.public_iface,
    vpn_network_address          = var.vpn_network_address,
    docker_compose_b64_encoded   = filebase64("${path.root}/uploads/docker-compose.yml"),
    nginx_conf_b64_encoded       = filebase64("${path.root}/uploads/nginx.conf"),
    setup_nginx_conf_b64_encoded = filebase64("${path.root}/uploads/setup_nginx.conf"),
    init_script_b64_encoded      = filebase64("${path.root}/uploads/init_script.sh"),
    setting_up_page_b64_encoded  = filebase64("${path.root}/uploads/index.html"),
    aws_account_id               = data.aws_caller_identity.current.account_id,
    region                       = var.region
  })

  associate_public_ip_address = true

  tags = {
    Name = "devsecops-2"
  } 
}