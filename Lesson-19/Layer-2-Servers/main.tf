provider "aws" {
  region = "ca-central-1"    
}


terraform {
  backend "s3" {
    bucket = "alena-kashirina-project-terraform-state"
    key    = "dev/servers/terraform.tfstate"
    region = "us-east-1"
  }
}

#---------------------------------------------------



data "terraform_remote_state" "network" {
  backend = "s3"  
  config = {
    bucket = "alena-kashirina-project-terraform-state"
    key    = "dev-network/terraform.tfstate"
    region = "us-east-1"
  }  
}

data "aws_ami" "latest_amazon_linux" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

#-----------------------------------------------------

resource "aws_instance" "web_server" {
  ami                    = data.aws_ami.latest_amazon_linux.id
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.webserver.id] 
  subnet_id              = data.terraform_remote_state.network.outputs.public_subnet_ids[0]
  user_data = <<EOF
#!/bin/bash
yum -y update
yum -y install httpd
myip=`curl http://169.254.169.254/latest/meta-data/local-ipv4`
echo "<h2>WebServer with IP: $myip</h2><br>Build by Terraform with Remote State"  >  /var/www/html/index.html
sudo service httpd start
chkconfig httpd on
EOF
  tags = {
    Name = "${var.env}-WebServer"
  }
}  




resource "aws_security_group" "webserver" {
  name = "WebServer Security Group"
  vpc_id = data.terraform_remote_state.network.outputs.vpc_id

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [data.terraform_remote_state.network.outputs.vpc_cidr]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.env}-web-server-sg"
    Owner = "Alena Kashirina"
  }
}


output "webserver_sg_id" {
  value = aws_security_group.webserver.id 
}

output "web_server_public_ip" {
  value = aws_instance.web_server.public_ip
}