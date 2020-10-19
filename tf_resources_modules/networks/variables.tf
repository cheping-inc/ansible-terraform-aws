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

variable "instance_type" {
  type    = string
  default = "t3.micro"
}
