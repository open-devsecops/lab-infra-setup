output "next_steps" {
  value = "Please refer to https://github.com/taehyunnkim/open-devsecops/tree/main/lab-setup/aws/topic-2-cicd-lab"
}

output "please_note" {
  value = [
    "Tool installation could take several minutes to complete.",
    "Verify completion by entering the following command on the server:",
    "grep 'Lab Infrastructure Provisioning Complete' /var/log/cloud-init-output.log"
  ]
}

output "SSH" {
  value = "ssh -i ${var.ssh_key_name}.pem ubuntu@${aws_instance.topic-2-lab.public_ip}"
}

output "ec2_public_ip" {
  value = aws_instance.topic-2-lab.public_ip
  description = "The public IP address of the EC2 instance."
}