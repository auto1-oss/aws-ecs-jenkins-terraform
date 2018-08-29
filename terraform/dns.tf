resource "aws_route53_zone" "private" {
  name    = "${var.internal_dns_zone}"
  vpc_id  = "${module.vpc.vpc_id}"
  comment = "internal DNS zone"
  tags    = "${merge(map("Name", var.internal_dns_zone), var.default_tags)}"
}

resource "aws_route53_record" "bastion" {
  zone_id = "${aws_route53_zone.private.zone_id}"
  name    = "${var.name_prefix}-bastion"
  type    = "A"
  ttl     = 300
  records = ["${module.ec2_bastion.private_ip[0]}"]
}

resource "aws_route53_record" "jenkins" {
  zone_id = "${aws_route53_zone.private.zone_id}"
  name    = "jenkins"
  type    = "A"

  alias {
    name                   = "${aws_lb.lb.dns_name}"
    zone_id                = "${aws_lb.lb.zone_id}"
    evaluate_target_health = true
  }
}

output "private_zone_name" {
  value = "${aws_route53_zone.private.name}"
}

output "private_zone_id" {
  value = "${aws_route53_zone.private.zone_id}"
}
