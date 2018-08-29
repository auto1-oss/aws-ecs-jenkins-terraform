variable "region" {
  description = "AWS region"
}

variable "name" {
  description = "Application name"
}

variable "container_port" {
  description = "Exposed port of your service container to be registered with LB"
  default     = 80
}

# TODO replace with actual data from ../../terraform
variable "remote_state" {
  description = "Remote state S3 parameters"
  type        = "map"

  default = {
    bucket = "myterraform-states"
    region = "eu-central-1"
    key    = "aws-berlin.tfstate"
  }
}
