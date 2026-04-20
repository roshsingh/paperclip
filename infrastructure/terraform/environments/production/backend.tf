terraform {
  backend "s3" {
    bucket         = "sparkmed-terraform-state-872443248397"
    key            = "paperclip/production/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "sparkmed-terraform-locks"
    encrypt        = true
  }
}
