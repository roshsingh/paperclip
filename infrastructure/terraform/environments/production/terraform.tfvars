# Copy to terraform.tfvars.local and set db_password, or use:
#   export TF_VAR_db_password='...'

environment = "production"
aws_region  = "us-east-1"
hostname    = "area51.robowise.ai"

db_password = "" # use TF_VAR_db_password

alarm_email = ""
