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
}

provider "aws" {
  region = "us-east-1"
}