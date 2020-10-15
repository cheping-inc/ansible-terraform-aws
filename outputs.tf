output "Jenkins-Maaster-Public-IP" {
  value = aws_instance.jenkins_master.public_ip
}

output "Jenkins-Worker-Public-IPs" {
  value = {
    for instance in aws_instance.jenkins_worker :
    instance.id => instance.public_ip
  }
}

#add LB DNS name to outputs
output "LB-DNS-NAME" {
  value = aws_lb.application_lb.dns_name
}