terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.67.0"
    }
  }

  backend "s3" {
    bucket = "aws-hidetake-org"
    key    = "terraform/hello-sfn/helloworld/v1.tfstate"
    region = "us-west-2"
  }
}

provider "aws" {
  region = "us-west-2"
}
