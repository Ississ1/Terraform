#----------------------------------------------------------
# My Terraform
#
# Terraform Conditions and Lookups
#
# Made by Alena Kashirina
#----------------------------------------------------------

provider "aws" {
  region = "eu-central-1"  
}


variable "env" {
  default = "prod"  
}


variable "prod_owner" {
  default = "Alena Kashirina"  
}

variable "noprod_owner" {
  default = "Dyadya Vasya"
}



variable "ec2_size" {
  default = {
    "prod"    = "t3.medium"
    "dev"     = "t3.micro"
    "staging" = "t2.small"
  }  
}


variable "allow_port_list" {
  default = {
    "prod" = ["80", "443"]
    "dev" = ["80", "443", "8080", "22"]
  }  
}

resource "aws_default_vpc" "default" {
}


resource "aws_instance" "my_webserver1" {
  ami           = "ami-03aefa83246f44ef2"
  //instance_type = (var.env == "prod" ? "t2.lafge" : "t2.micro")
  instance_type = var.env == "prod" ? var.ec2_size["prod"] : var.ec2_size["dev"]

  tags = {
    Name = "${var.env}-server"
    Owner = var.env == "prod" ? var.prod_owner : var.noprod_owner
  }
}


resource "aws_instance" "my_webserver2" {
  ami           = "ami-03aefa83246f44ef2"
  instance_type = lookup (var.ec2_size, var.env)

  tags = {
    Name = "${var.env}-server"
    Owner = var.env == "prod" ? var.prod_owner : var.noprod_owner
  }
}

  
  resource "aws_instance" "my_dev_bastion" {
    count         = var.env == "dev" ? 1 : 0
    ami           = "ami-03aefa83246f44ef2"
    instance_type = "t2.micro"

    tags = {
      Name = "Bastion Server for Dev-server"
  }
}


resource "aws_security_group" "my_webserver" {
  name   = "Dynamic Security Group"
  vpc_id = aws_default_vpc.default.id # This need to be added since AWS Provider v4.29+ to set VPC id


  dynamic "ingress" {
    for_each = lookup(var.allow_port_list, var.env)
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name  = "Dynamic SecurityGroup"
    Owner = "Alena Kashirina"
  }
}