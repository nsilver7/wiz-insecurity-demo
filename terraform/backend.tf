terraform {
  backend "s3" {
    bucket  = "wiz-insecurity-terraform-state-bucket"
    key     = "projects/wiz-insecurity-demo/terraform.tfstate"
    region  = "us-west-2"
    encrypt = true
  }
}