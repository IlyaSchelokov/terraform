terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  aws = {
      source = "hashicorp/aws"
      version = "5.26.0"
    }
  }
}

provider "digitalocean" {
 token = var.access_token
}

 
provider "aws" {
  region     = "us-west-2"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}
