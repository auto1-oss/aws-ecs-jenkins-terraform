#
# This file is part of the auto1-oss/aws-ecs-jenkins-terraform.
#
# (c) AUTO1 Group SE https://www.auto1-group.com
#
# For the full copyright and license information, please view the LICENSE
# file that was distributed with this source code.
#

# Application loadbalancer for jenkins and applications
resource "aws_lb" "lb" {
  name     = "${var.name_prefix}-ecs"
  internal = true
  subnets  = ["${module.vpc.private_subnets}"]

  security_groups = [
    "${aws_security_group.internal.id}",
  ]

  tags = "${merge(map("Name", format("%s-ecs", var.name_prefix)), var.default_tags)}"
}

resource "aws_lb_target_group" "default" {
  name     = "${var.name_prefix}-ecs-default"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${module.vpc.vpc_id}"

  tags = "${merge(map("Name", format("%s-ecs-default", var.name_prefix)), var.default_tags)}"
}

resource "aws_lb_listener" "web" {
  load_balancer_arn = "${aws_lb.lb.arn}"
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.default.arn}"
  }
}

output "lb_http_listener_arn" {
  value = "${aws_lb_listener.web.arn}"
}

output "lb_dns_name" {
  value = "${aws_lb.lb.dns_name}"
}

output "lb_zone_id" {
  value = "${aws_lb.lb.zone_id}"
}
