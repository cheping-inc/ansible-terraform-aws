variable "profile" {
  type    = string
  default = "default"
}

variable "region_master" {
  type    = string
  default = "us-east-1"
}

variable "region_worker" {
  type    = string
  default = "us-east-2"
}

variable "external_ip" {
  type    = string
  default = "0.0.0.0/0"
}

variable "workers_count" {
  type    = number
  default = 1
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "webserver_port" {
  type    = number
  default = 8080
}

#variable "dns_name" {
#  type    = string
#  default = ""
#}