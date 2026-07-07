terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Local backend, state kept separate per environment via the path below.
  # For a real multi-engineer dev environment, swap this for a remote
  # backend, e.g.:
  #
  # backend "s3" {
  #   bucket         = "hotel-booking-tfstate-dev"
  #   key            = "dev/terraform.tfstate"
  #   region         = "ap-south-1"
  #   dynamodb_table = "hotel-booking-tf-locks"
  #   encrypt        = true
  # }
  backend "local" {
    path = "dev.tfstate"
  }
}

provider "aws" {
  region                      = var.aws_region
  skip_credentials_validation = var.skip_aws_account_lookup
  skip_requesting_account_id  = var.skip_aws_account_lookup
  skip_region_validation      = var.skip_aws_account_lookup
  skip_metadata_api_check     = var.skip_aws_account_lookup
}
