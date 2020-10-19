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

variable "masters_count" {
  type    = number
  default = 0
}

variable "workers_count" {
  type    = number
  default = 0
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "external_ip" {
  type    = string
  default = "0.0.0.0/0"
}

variable "webserver_port" {
  type    = number
  default = 8080
}

variable "subnet_worker_id"{
  type = string
}

variable "jenkins_sg_master_id" {
  type = string
}

variable "jenkins_sg_worker_id" {
  type = string
}

variable "subnet_master_1_id" {
  type = string
}

variable "set_master_default_rt_assoc" {
  type = any
}

variable "set_worker_default_rt_assoc" {
  type = any
}