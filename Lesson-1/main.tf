provider "aws" {

}
 resource "aws_instance" "my_Amazon" {
  ami           = "ami-0499632f10efc5a62" 
  instance_type = "t2.micro"  
  
  tags = {
    Name    = "My Amazon Server"
    Owner   = "Alena Kashirina"
    Project = "Terraforn Lessons"
  }           
}



