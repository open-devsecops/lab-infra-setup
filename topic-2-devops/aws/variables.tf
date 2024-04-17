variable "ec2_lab_instance_type" {
  type    = string
  default = "t3.medium"
}

variable "ssh_key_name" {
  type    = string
  default = "topic-2-cicd-lab-key"
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