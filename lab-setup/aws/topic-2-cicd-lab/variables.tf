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