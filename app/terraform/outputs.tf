#
# This file is part of the auto1-oss/aws-ecs-jenkins-terraform.
#
# (c) AUTO1 Group SE https://www.auto1-group.com
#
# For the full copyright and license information, please view the LICENSE
# file that was distributed with this source code.
#

output "ecr_url" {
  value = "${aws_ecr_repository.ecr.repository_url}"
}

output "application_endpoint" {
  value = "http://${var.name}.${data.terraform_remote_state.remote.private_zone_name}"
}
