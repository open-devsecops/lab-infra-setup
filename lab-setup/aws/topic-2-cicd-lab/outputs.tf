output "public_ip" {
  description = "The public IP address assigned to the instance."
  value = ["${aws_instance.topic-2-lab.*.public_ip}"]
}