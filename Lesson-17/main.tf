#----------------------------------------------------------
# My Terraform
#
# Terraform Loops: Count and For if
#
# Made by Alena Kashirina
#----------------------------------------------------------

provider "aws" {
  region = "ca-central-1"
}


variable "aws_users"{
  description = "List of IAM Users to create" 
  default = ["vasya", "petya", "kolya", "lena", "masha", "misha", "alisa", "donald"]    
}


resource "aws_iam_user" "user1" {
  name = "shevchenko"  
}

resource "aws_iam_user" "users" {
  count = length(var.aws_users)    
  name = element(var.aws_users, count.index)
}

output "created_iam_users_all" {
  value = aws_iam_user.users    
}

output "created_iam_users_ids" {
  value = aws_iam_user.users[*].id    
}

output "created_iam_users_cistom" {
  value = [
    for user in aws_iam_user.users:
    "Username: ${user.name} has ARN: ${user.arn}" 
  ]    
}

output "created_iam_users_map" {
  value = {
    for user in aws_iam_user.users:
    user.unique_id => user.id  
  }    
}


// Print List of users with name 4 characters ONLY
output "custom_if_length" {
  value = [
    for x in aws_iam_user.users:
    x.name
    if length(x.name) == 4
  ]    
}



#-----------------------------------------------------

resource "aws_instance" "servers" {
  count = 3  
  ami = "ami-07ab3281411d31d04"    
  instance_type = "t2.micro"
  tags = {
    Name = "Server Number ${count.index + 1}"
  }
}


// Print nice MAP of InstanceID: PublicIP
output "server_all" {
  value = {
    for server in aws_instance.servers :
    server.id => server.public_ip  
  }    
}