#
# This file is part of the auto1-oss/aws-ecs-jenkins-terraform.
#
# (c) AUTO1 Group SE https://www.auto1-group.com
#
# For the full copyright and license information, please view the LICENSE
# file that was distributed with this source code.
#

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
