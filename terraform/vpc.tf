#
# This file is part of the auto1-oss/aws-ecs-jenkins-terraform.
#
# (c) AUTO1 Group SE https://www.auto1-group.com
#
# For the full copyright and license information, please view the LICENSE
# file that was distributed with this source code.
#

module "vpc" {
  source = "github.com/terraform-aws-modules/terraform-aws-vpc?ref=v1.37.0"

  name = "${var.name_prefix}-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["${var.region}a", "${var.region}b", "${var.region}c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway           = true
  enable_vpn_gateway           = false
  create_database_subnet_group = false

  enable_dhcp_options  = true
  enable_dns_hostnames = true
  enable_dns_support   = true

  dhcp_options_domain_name         = "${var.internal_dns_zone}"
  dhcp_options_domain_name_servers = ["AmazonProvidedDNS"]

  tags = "${merge(map("Name", var.name_prefix), var.default_tags)}"
}

output "vpc_id" {
  value = "${module.vpc.vpc_id}"
}
