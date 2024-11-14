variable "instance_module_ami" {
  type = string
  }

variable "instance_module_type" {
  type = string
}

variable "subnet_id" {
    description = "get the subnet id after creation"
    type = string
}

variable "public_ip" {
  type = bool
  default = true
}
