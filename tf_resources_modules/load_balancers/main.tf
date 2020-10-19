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

#create lb
resource "aws_lb" "application_lb" {
  provider           = aws.region_master
  name               = "jenkins-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.lb_sg_id]
  subnets            = [var.subnet_master_1_id, var.subnet_master_2_id]

  tags = {
    Name = "Jenkins-LB"
  }
}

#create the target group on one instance
resource "aws_lb_target_group" "app_lb_tg" {
  provider    = aws.region_master
  name        = "app-lb-tg"
  port        = var.webserver_port
  target_type = "instance"
  vpc_id      = var.vpc_master_id
  protocol    = "HTTP"
  health_check {
    enabled  = true
    interval = 10
    path     = "/"
    port     = var.webserver_port
    protocol = "HTTP"
    matcher  = "200-299"
  }

  tags = {
    Name = "jenkins-master-target-group"
  }
}

resource "aws_lb_listener" "jenkins_listener_http" {
  provider          = aws.region_master
  load_balancer_arn = aws_lb.application_lb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_lb_tg.id
  }
}

resource "aws_lb_target_group_attachment" "jenkins_master_attach" {
  provider         = aws.region_master
  target_group_arn = aws_lb_target_group.app_lb_tg.arn
  target_id        = var.jenkins_master_id
  port             = var.webserver_port
}
