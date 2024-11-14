variable "vpc_aws" {
  type    = string
  default = "10.0.0.0/16"
}

variable "ami_instance" {
  type    = string
  default = "ami-0182f373e66f89c85"
}

variable "instance_type_aws" {
  type    = string
  default = "t2.micro"
}

variable "available_zone" {
  type    = string
  default = "us-east-1"

}

variable "environment" {
  type        = string
  description = "choose the environment"
  #default = "stage"
}
