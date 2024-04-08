variable "region" {
    type = string
    default = "ap-south-1"
}

variable "access_key" {
    type = string
    default = ""
}
variable "secret_key" {
    type = string
    default = ""
}
variable "cidr_block" {
    type = string
    default = "10.0.0.0/16"
}
variable "availability_zone" {
    type = string
    default = "ap-south-1a"
}
# variable "private_ips" {
#     type = list
#     default = ["10.0.1.50"]

variable "ami" {
    type = string
    default = "ami-03a933af70fa97ad2"
}
variable "instance_type" {
    type = string
    default = "t2.micro"
  
}

  
