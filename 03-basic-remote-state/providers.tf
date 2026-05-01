terraform {

  required_providers {

    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.4.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.8.1"
    }

  }

  # stores Terraform's state file in this bucket
  # the bucket listed below must already exist
  backend "s3" {
    bucket = "my-example-bucket"
    key    = "state.tfstate"
    region = "us-east-1"
  }

}

provider "aws" {
  region = "us-east-1"
}