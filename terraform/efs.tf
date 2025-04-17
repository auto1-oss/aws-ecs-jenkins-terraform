#
# This file is part of the auto1-oss/aws-ecs-jenkins-terraform.
#
# (c) AUTO1 Group SE https://www.auto1-group.com
#
# For the full copyright and license information, please view the LICENSE
# file that was distributed with this source code.
#

resource "aws_efs_file_system" "ecs" {
  creation_token   = "${var.name_prefix}-ecs"
  performance_mode = "generalPurpose"

  tags = "${merge(map("Name", format("%s-ecs", var.name_prefix)), var.default_tags)}"
}

resource "aws_efs_mount_target" "efs-client" {
  # depends on vpc module, that's why count can't be computed, hardcoded manually
  count           = 3
  file_system_id  = "${aws_efs_file_system.ecs.id}"
  subnet_id       = "${module.vpc.private_subnets[count.index]}"
  security_groups = ["${aws_security_group.internal.id}"]
}
