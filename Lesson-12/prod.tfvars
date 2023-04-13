# Auto Fill parametrs for DEV

#File can be names as:
# terraform.tfvars
# prod.auto.tfvars
# dev.auto.tfvars

region                     = "ca-central-1"
instance_type              = "t2.micro"
enable_detailed_monitoring = true

allow_ports = ["80", "443"]

common_tags = {
    Owner       = "Denis Astahov"
    Project     = "Phoenix"
    CostCenter  = "123477"
    Environment = "prod"
  }

