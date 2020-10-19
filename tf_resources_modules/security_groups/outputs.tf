output "jenkins_sg_master_id" {
    value = aws_security_group.jenkins_sg_master.id
}

output "jenkins_sg_worker_id" {
    value = aws_security_group.jenkins_sg_worker.id
}

output "lb_sg_id" {
    value = aws_security_group.lb_sg.id
}
