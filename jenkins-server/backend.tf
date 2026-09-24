terraform {
  backend "s3" {
    bucket = "aryans-terraform-state-bucket"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}