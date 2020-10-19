output "Jenkins-Master-Public-IP" {
  value = aws_instance.jenkins_master.public_ip
}

output "Jenkins-Worker-Public-IPs" {
  value = {
    for instance in aws_instance.jenkins_worker :
    instance.id => instance.public_ip
  }
}

output "jenkins_master_id" {
  value = aws_instance.jenkins_master.id
}