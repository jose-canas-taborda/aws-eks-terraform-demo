terraform {
    required_version = ">= 0.12.0"
    backend "s3" {
        encrypt = true
        bucket = "envio-demo-terraform-state"
        key    = "eks_aws/states"
        region = "us-east-1"
    }
}

provider "aws" {
    version = ">= 2.28.1"
    region  = var.region
}

# create an S3 bucket to store the state file in
resource "aws_s3_bucket" "envio-demo-terraform-state" {
    bucket = "envio-demo-terraform-state"
 
    versioning {
      enabled = true
    }
 
    lifecycle {
      prevent_destroy = false
    }
 
    tags = {
      Name = "S3 Remote Terraform State Store"
    }      
}