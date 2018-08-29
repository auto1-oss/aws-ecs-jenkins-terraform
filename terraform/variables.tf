variable "region" {}
variable "name_prefix" {}
variable "internal_dns_zone" {}
variable "ssh_key" {}
variable "states_bucket" {}
variable "jenkins_password" {}

variable "default_tags" {
  type = "map"
}
