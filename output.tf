output "aws_subnet" {
  value = module.aws_subnet_module.subnet_id
 }

output "aws_instance" {
  description = "get the instance details"
  value = module.aws_instance_module.instance_ip
}