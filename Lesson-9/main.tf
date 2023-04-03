#---------------------------------------------
# My Terraform
#
# Find Latest AMI id of:
#    - Ubuntu 18.04
#    - Amazon Linux 2
#    - Windows Server 2016 Base
#
# Made by Alena Kashirina
#---------------------------------------------


provider "aws" {
  region = "ap-southeast-2"  
}

data "aws_ami" "latest_ubuntu" {
  owners      = ["099720109477"]
  most_recent = true
  filter {
     name   = "name"
     values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }  
}

data "aws_ami" "latest_amazon_linux" {
  owners      = ["amazon"]
  most_recent = true 
  filter {
    name   = "name"
    values = ["al2023-ami-2023.0.20230322.0-kernel-6.1-x86_64"]
  } 
}

data "aws_ami" "latest_windows_2016" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["Windows_Server-2022-English-Full-Base-*"]
  }  
}

resource "aws_instance" "my_webserver_ubuntu" {
ami                    = "data.aws_ami.latest_ubuntu.name"   # Amazon Linux AMI
instance_type          = "t2.micro"
}

output "latest_windows_2016_ami_id" {
  value = data.aws_ami.latest_windows_2016.id
}

output "latest_windows_2016_ami_name" {
  value = data.aws_ami.latest_windows_2016.name
}

output "latest_amazon_linux_ami_id" {
  value = data.aws_ami.latest_amazon_linux.id
}

output "latest_amazon_linux_ami_name" {
  value = data.aws_ami.latest_amazon_linux.name
}

output "latest_ubuntu_ami_id" {
  value = data.aws_ami.latest_ubuntu.id
}

output "latest_ubuntu_ami_name" {
  value = data.aws_ami.latest_ubuntu.name
}