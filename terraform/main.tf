# This bucket holds all infrastructure states so it should be created before apply
# Can be imported in state later, change this to your bucket or comment out
terraform {
  backend "s3" {
    bucket = "myterraform-states"
    key    = "aws-berlin.tfstate"
    region = "eu-central-1"
  }

  required_version = "~> 0.11.7"
}

# terraform and provider configuration
provider "aws" {
  region  = "${var.region}"
  version = "~> 1.30"
}
