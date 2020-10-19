variable "region_master" {
    type= string
}

variable "region_worker" {
    type= string
}

variable "profile" {
  type    = string
  default = "default"
}

variable "workers_count" {
  type    = number
  default = 0
}

variable "webserver_port" {
  type    = number
  default = 8080
}

variable "external_ip" {
  type    = string
}



variable "jenkins_master_id" {
  type = string
}

variable "lb_sg_id"{
type    = string
}

variable "subnet_master_1_id"{
  type    = string
}

variable "subnet_master_2_id"{
  type    = string
}

variable "vpc_master_id"{
  type    = string
}
