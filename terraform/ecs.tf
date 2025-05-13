#
# This file is part of the auto1-oss/aws-ecs-jenkins-terraform.
#
# (c) AUTO1 Group SE https://www.auto1-group.com
#
# For the full copyright and license information, please view the LICENSE
# file that was distributed with this source code.
#

resource "aws_ecs_cluster" "cluster" {
  name = "${var.name_prefix}"
}

output "ecs_cluster" {
  value = "${aws_ecs_cluster.cluster.name}"
}
