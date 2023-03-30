#------------------------------------------
# My Terraform
#
# Build Webserver during Bootsrap
#
# Made by Alena Kashirina
#------------------------------------------


provider "aws" {
  region = "eu-central-1" 
}

resource "aws_default_vpc" "default" {
}

resource "aws_eip" "my_static_ip" {
  instance = aws_instance.my_webserver.id
}
resource "aws_instance" "my_webserver" {
  ami                    = "ami-0499632f10efc5a62"   # Amazon Linux AMI
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.my_webserver.id]
  user_data              = templatefile("user_data.sh.tpl", {
    f_name = "Alena",
    l_name = "Kashirina",
    names  = ["Vasya", "Kolya", "Petya", "John", "Donald", "Masha", "Test"]
  })
   user_data_replace_on_change = true

  tags = {
    Name  = "Web Server Build by Terraform"
    Owner = "Alena Kashirina"
  }

  lifecycle {
    create_before_destroy = true
 }
} 
 
resource "aws_security_group" "my_webserver" {
  name        = "Webserver Security Group"
  description = "My First SecurityGroup"
  vpc_id      = aws_default_vpc.default.id

  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Web Server SecurityGroup"
    Owner = "Alena Kashirina"
  }

}