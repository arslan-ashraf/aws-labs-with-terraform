terraform {
  required_providers {

    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.4.0"
    }

  }
}

provider "aws" {
  region = "us-east-1"
  alias  = "region_US_east"
}

provider "aws" {
  region = "ap-northeast-1"
  alias  = "region_Tokyo"
}
