variable "region" {
  type    = string
  default = "us-east-1"
}

variable "name" {
  type    = string
  default = "devops"
}

variable "instance_type" {
  type    = string
  default = "t2.large"
}

variable "key_name" {
  type = string
}

variable "ssh_cidr" {
  type    = string
  default = "0.0.0.0/0"
}
