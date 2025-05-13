#
# This file is part of the auto1-oss/aws-ecs-jenkins-terraform.
#
# (c) AUTO1 Group SE https://www.auto1-group.com
#
# For the full copyright and license information, please view the LICENSE
# file that was distributed with this source code.
#

variable "region" {}
variable "name_prefix" {}
variable "internal_dns_zone" {}
variable "ssh_key" {}
variable "states_bucket" {}
variable "jenkins_password" {}

variable "default_tags" {
  type = "map"
}
