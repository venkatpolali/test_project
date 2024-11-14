locals {
  region_env = "us-east-1"
  custom_instance_type = {
    dev  = "t2.micro"
    prod = "t2.small"
  }
  environment    = var.environment
  final_instance = lookup(local.custom_instance_type, local.environment, "dev")
  #final_region   = local.region_env[local.environment]
}

provider "aws" {
  region                   = local.region_env
  shared_credentials_files = ["C:\\Users\\w191397\\OneDrive - Worldline SA\\Documents\\Zabbix\\credentials"]
}

data "aws_availability_zones" "available" {}
data "aws_region" "current" {}


resource "aws_instance" "my_instance" {
  ami           = var.ami_instance
  instance_type = local.final_instance
  depends_on    = [aws_subnet.test_subnet, local_file.aws_key_pair] 
  associate_public_ip_address = true
  subnet_id     = aws_subnet.test_subnet.id
  key_name = "aws_key_test"
  tags = {
    Name = "MyEC2Instance-${local.environment}-${local.final_instance}"
    region = data.aws_region.current.name
  }
}

resource "null_resource" "wait" {
  depends_on = [ aws_instance.my_instance ]
  provisioner "local-exec" {
    command = "sleep 60"
  }
}
resource "null_resource" "remote_exec" {
  depends_on = [aws_instance.my_instance]

  provisioner "remote-exec" {
    inline = ["sudo apt update"]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      host        = aws_instance.my_instance.public_ip
      private_key = tls_private_key.tf-key-private.private_key_pem
    }
  }
}

resource "aws_vpc" "test_vpc" {
  cidr_block = var.vpc_aws
}

resource "aws_subnet" "test_subnet" {
  vpc_id     = aws_vpc.test_vpc.id
  cidr_block = aws_vpc.test_vpc.cidr_block
  depends_on = [aws_vpc.test_vpc]
  #availability_zone = tolist(data.aws_availability_zones.available)
}

resource "aws_s3_bucket" "test_bucket" {
  bucket        = "my-tf-${local.environment}-bucket-${aws_instance.my_instance.id}"
  force_destroy = true


  tags = {
    Name        = "My bucket"
    Environment = local.environment
  }
}

resource "tls_private_key" "tf-key-private" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "tf-key" {
  key_name = "aws_key_test"
  public_key = tls_private_key.tf-key-private.public_key_openssh
}

resource "local_file" "aws_key_pair" {
  content  = tls_private_key.tf-key-private.private_key_pem
  filename = "tf-keys-ssh"
}

resource "aws_security_group" "test_group_security" {
  name        = "web_server_port"
  description = "allow traffic from port 443"
  vpc_id      = aws_vpc.test_vpc.id

  ingress {
    description = "allow 443"
    from_port   = 443
    to_port     = 446
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "allow 80 port"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }
   egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "allow 443"
    from_port   = 443
    to_port     = 445
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "keys_output" {
  value = tls_private_key.tf-key-private
  sensitive = true
}


output "keys_output_1" {
  value = aws_key_pair.tf-key
  sensitive = true
}

resource "aws_instance" "import_instance" {
  
}

