provider "aws" {
  region = "ca-central-1"  
}


variable "name" {
  default = "petya"  
}

resource "random_string" "rds_password" {
  length           = 12
  special          = true
  override_special = "!#$&" 
  keepers = {
   keeper1 = var.name
   // kepeer2 = var.something 
  }   
}

resource "aws_ssm_parameter" "rds_password" {
  name        = "/prod/mysql"
  description = "Master Password for RDS MySQL"
  type        = "SecureString"
  value       = random_string.rds_password.result
}



data "aws_ssm_parameter" "my_rds_password" {
  name = "/prod/mysql"
  depends_on = [aws_ssm_parameter.rds_password]  
}


resource "aws_db_instance" "default" {
  identifier              = "prod-rds"
  allocated_storage       = 20
  storage_type            = "gp2"
  engine                  = "mysql"
  engine_version          = "5.7"
  instance_class          = "db.t2.micro"
  db_name                 = "prod"
  username                = "administrator"
  password                = data.aws_ssm_parameter.my_rds_password.value
  parameter_group_name    = "default.mysql5.7"
  skip_final_snapshot     = true
  apply_immediately       = true
}




output "rds_password" {
  value = data.aws_ssm_parameter.my_rds_password.value
  sensitive = true
}