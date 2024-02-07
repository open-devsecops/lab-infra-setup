variable "ec2_instance_type" {
  type    = string
  default = "t3.medium"
}

variable "ssh_key_name" {
  type    = string
  default = "topic-2-cicd-lab-key"
}