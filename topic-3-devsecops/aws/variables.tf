variable "ec2_lab_instance_type" {
  type    = string
  default = "t3.large"
}

variable "ec2_block_size" {
  type    = number
  default = 30
}

variable "ssh_key_name" {
  type    = string
  default = "topic-3-devsecops-lab-key"
}

variable "availability_zone" {
 type        = string
 description = "Availability Zone"
 default     = "us-west-1a"
}

variable "region" {
 type        = string
 default     = "us-west-1"
}

variable "wg_port" { 
  type = number
  default = 21210 
}

variable "public_iface" { 
  type = string
  default = "ens5" 
}

variable "vpn_network_address" {
  type = string
  default = "192.168.77.1/24"
}