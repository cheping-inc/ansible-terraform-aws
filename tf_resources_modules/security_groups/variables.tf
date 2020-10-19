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

variable "external_ip" {
  type    = string
  default = "0.0.0.0/0"
}

variable "webserver_port" {
  type    = number
  default = 8080
}



variable "vpc_master_id" {
  type = string
}

variable "vpc_worker_id" {
  type = string
}