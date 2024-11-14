provider "aws" {
  region     = var.aws_default_region
}

data "aws_availability_zones" "available" {}
data "aws_region" "current" {}

module "aws_vpc_module" {
    source = ".\\modules\\network_module"
    vpc_cidr = var.vpc_variable
}

module "aws_subnet_module" {
  source = ".\\modules\\subnet_module"
  vpc_id = module.aws_vpc_module.vpc_id
  cidr_subnet = var.subnet_cidr_block
}

module "aws_instance_module" {
  source = ".\\modules\\instance_module"
  instance_module_ami = var.aws_test_instance_ami
  instance_module_type = var.aws_test_instance_type
  subnet_id = module.aws_subnet_module.subnet_id
}

/*resource "aws_instance" "my_instance" {
  ami           = var.aws_test_instance
  instance_type = "t2.micro"
  subnet_id = aws_subnet.test_subnet["subnet_variable_1"].id
  associate_public_ip_address = true
  depends_on = [ aws_vpc.test_vpc ]

  tags = {
    Name = "Test_Instance"
  }
}*/

resource "aws_s3_bucket" "test_bucket" {
  bucket        = "vegatestbucket12243"
  force_destroy = true


  tags = {
    Name        = "My bucket"
    #Environment = local.environment
  }
}
