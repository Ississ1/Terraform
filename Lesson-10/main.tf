#----------------------------------------------------------
# Provision Highly Availabe Web in any Region Default VPC
# Create:
#    - Security Group for Web Server and ALB
#    - Launch Template with Auto AMI Lookup
#    - Auto Scaling Group using 2 Availability Zones
#    - Application Load Balancer in 2 Availability Zones
#    - Application Load Balancer TargetGroup
# Update to Web Servers will be via Green/Blue Deployment Strategy
# Made by Alena Kashirina 04.04.2023
#-----------------------------------------------------------

provider "aws" {
  region = "eu-west-2" 
}

data "aws_availability_zones" "available" {}
data "aws_ami" "latest_amazon_linux" {
  owners      = ["amazon"]
  most_recent = true 
  filter {
    name   = "name"
    values = ["al2023-ami-2023.0.20230322.0-kernel-6.1-x86_64"]
  } 
}

#-------------------------------------------------------------

resource "aws_default_vpc" "default" {} # This need to be added since AWS Provider v4.29+ to get VPC id

resource "aws_security_group" "web" {
  name   = "Dynamic Security Group"
  vpc_id = aws_default_vpc.default.id # This need to be added since AWS Provider v4.29+ to set VPC id

  dynamic "ingress" {
    for_each = ["80", "443"]
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


resource "aws_launch_configuration" "web" {
  //// name          = "WebBServer-Highly-Available-LC"
  name_prefix   = "WebBServer-Highly-Available-LC1-"
  image_id      = data.aws_ami.latest_amazon_linux.id
  instance_type = "t2.micro"
  security_groups = [aws_security_group.web.id]
  user_data = file("user_data.sh")

  lifecycle {
    create_before_destroy = true 
  }
}

resource "aws_autoscaling_group" "web" {
  name                 = "ASG-${aws_launch_configuration.web.name}"
  launch_configuration = aws_launch_configuration.web.name
  min_size             = "2"
  max_size             = "2"
  min_elb_capacity     = "2"
  health_check_type    = "ELB"
  vpc_zone_identifier  = [aws_default_subnet.default_az1.id, aws_default_subnet.default_az2.id]
  load_balancers       = [aws_elb.web.name]


  dynamic "tag" {
    for_each = {
      Name   = "WebServer in ASG"
      Owner  = "Alena Kashirina"
      TAGKEY = "TAGVALUE"
    }  

   content {
       key                 = tag.key
       value               = tag.value
       propagate_at_launch = true  
     }
    }

    lifecycle {
      create_before_destroy = true 
    }
}    
    
resource "aws_elb" "web" {
  name                  = "WebServer-HA-ELB"
  availability_zones    = [data.aws_availability_zones.available.names[0], data.aws_availability_zones.available.names[1]] 
  security_groups       = [aws_security_group.web.id] 
  listener {
    lb_port           = 80
    lb_protocol       = "http"
    instance_port     = 80
    instance_protocol = "http"
  }
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 10
  }
  tags = {
    Name = "WebServer-Highly-Available-ELB"
  }
}

resource "aws_default_subnet" "default_az1" {
   availability_zone = data.aws_availability_zones.available.names[0]
}

resource "aws_default_subnet" "default_az2" {
   availability_zone = data.aws_availability_zones.available.names[1]
}

#-------------------------------------------------

output "web_loadbalancer_url" {
  value = aws_elb.web.dns_name
}