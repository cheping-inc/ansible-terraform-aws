#Get Linux AMI ID using SSM from endpoint in master region
data "aws_ssm_parameter" "linuxAmi_Master" {
  provider = aws.region_master
  name     = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

#Get Linux AMI ID using SSM from endpoint in worker region
data "aws_ssm_parameter" "linuxAmi_Worker" {
  provider = aws.region_worker
  name     = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

#create key-pair for worker ec2
resource "aws_key_pair" "master_key" {
  provider   = aws.region_master
  key_name   = "jenkins"
  public_key = file("~/.ssh/id_rsa.pub")
}

#create key-pair for worker ec2
resource "aws_key_pair" "worker_key" {
  provider   = aws.region_worker
  key_name   = "jenkins"
  public_key = file("~/.ssh/id_rsa.pub")
}

#create EC2 instance for jenkins master
resource "aws_instance" "jenkins_master" {
  provider                    = aws.region_master
  ami                         = data.aws_ssm_parameter.linuxAmi_Master.value
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.master_key.key_name
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.jenkins_sg_master.id]
  subnet_id                   = aws_subnet.subnet_master_1.id

  tags = {
    Name    = "jenkins_master_tf"
    purpose = "terraform"
  }

  depends_on = [aws_main_route_table_association.set-master-default-rt-assoc]

  #  provisioner "local-exec" {
  #    command = <<EOF
  #aws --profile ${var.profile} ec2 wait instance-status-ok --region ${var.region_master} --instance-ids ${self.id}
  #ansible-playbook --extra-vars 'passed_in_hosts=tag_Name_${self.tags.Name}' ansible_templates/jenkins-master-sample.yml
  #EOF
  #  }
}

#install components on EC2 jenkins master instance 
resource "null_resource" "install_jenkins_master" {

  triggers = {
    key = "${uuid()}"
  }

  depends_on = [aws_instance.jenkins_master]

  provisioner "local-exec" {
    command = "ansible-playbook --extra-vars 'passed_in_hosts=tag_Name_${aws_instance.jenkins_master.tags.Name}' ansible_templates/jenkins-master-sample.yml"
  }
}

#create EC2 instance for jenkins worker
resource "aws_instance" "jenkins_worker" {
  provider                    = aws.region_worker
  count                       = var.workers_count
  ami                         = data.aws_ssm_parameter.linuxAmi_Worker.value
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.worker_key.key_name
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.jenkins_sg_worker.id]
  subnet_id                   = aws_subnet.subnet_worker.id

  tags = {
    Name    = join("_", ["jenkins_worker_tf", count.index + 1])
    purpose = "terraform"
  }

  depends_on = [aws_main_route_table_association.set-worker-default-rt-assoc, aws_instance.jenkins_master]

  #  provisioner "local-exec" {
  #    command = <<EOF
  #aws --profile ${var.profile} ec2 wait instance-status-ok --region ${var.region_worker} --instance-ids ${self.id}
  #ansible-playbook --extra-vars 'passed_in_hosts=tag_Name_${self.tags.Name}' ansible_templates/jenkins-worker-sample.yml
  #EOF
  #  }
  
  #provisioner "remote-exec" {
  #  when = destroy
  #  inline = [
  #    "java -jar /home/ec2-user/jenkins-cli.jar -auth @/home/ec2-user/jenkins_auth -s http://${aws_instance.jenkins_master.private_ip}:8080 delete-node ${self.private_ip}"
  #  ]
  #  connection {
  #    type = "ssh"
  #    user = "ec2-user"
  #    private_key = file("~/.ssh/id_rsa")
  #    host = self.public_ip
  #  }
  #}
}

#install components on EC2 jenkins worker instance 
resource "null_resource" "install_jenkins_worker" {
  count      = var.workers_count
  depends_on = [aws_instance.jenkins_master, aws_instance.jenkins_worker]

  provisioner "local-exec" {
    command = "ansible-playbook --extra-vars 'passed_in_hosts=tag_Name_${aws_instance.jenkins_worker[count.index].tags.Name}' ansible_templates/jenkins-worker-sample.yml"
  }
  
}