provider "aws" {
  region  = var.region_master
  profile = var.profile
  alias   = "region_master"
}

provider "aws" {
  region  = var.region_worker
  profile = var.profile
  alias   = "region_worker"
}

#create SG for LB, only TCP/80 TCP/443 and outbound access
resource "aws_security_group" "lb_sg" {
  provider    = aws.region_master
  name        = "lb-sg"
  description = "Allow 443 and traffic to Jenkins SG"
  vpc_id      = var.vpc_master_id
  ingress {
    description = "Allow 443 from anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Allow 80 from anywhere to redirection"
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    description = "Allow all"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create SG allowing TCP/8080 and TCP/22 from your IP in master region
resource "aws_security_group" "jenkins_sg_master" {
  provider    = aws.region_master
  name        = "jenkins-sg-master"
  description = "Allow TCP 8080 and SSH 22"
  vpc_id      = var.vpc_master_id
  ingress {
    description     = "Allow 8080 from anywhere"
    from_port       = var.webserver_port
    to_port         = var.webserver_port
    protocol        = "TCP"
    security_groups = [aws_security_group.lb_sg.id]
  }
  ingress {
    description = "Allow 22 from our public IP"
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = [var.external_ip]
  }
  ingress {
    description = "Allow traffic from worker"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.2.1.0/24"]
  }
  egress {
    description = "Allow all"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create SG allowing TCP/22 from your IP in worker region
resource "aws_security_group" "jenkins_sg_worker" {
  provider    = aws.region_worker
  name        = "jenkins-sg-worker"
  description = "Allow TCP/22"
  vpc_id      = var.vpc_worker_id
  ingress {
    description = "Allow 22 from our public IP"
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = [var.external_ip]
  }
  ingress {
    description = "Allow traffic from master"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.1.1.0/24"]
  }
  egress {
    description = "Allow all"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

