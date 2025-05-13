#
# This file is part of the auto1-oss/aws-ecs-jenkins-terraform.
#
# (c) AUTO1 Group SE https://www.auto1-group.com
#
# For the full copyright and license information, please view the LICENSE
# file that was distributed with this source code.
#

# SSH key to access instances
resource "aws_key_pair" "default" {
  key_name   = "${var.name_prefix}-ssh-key"
  public_key = "${var.ssh_key}"
}

data "aws_ami" "amazon_linux" {
  most_recent = true

  filter {
    name = "name"

    values = [
      "amzn-ami-hvm-*-x86_64-gp2",
    ]
  }

  filter {
    name = "owner-alias"

    values = [
      "amazon",
    ]
  }
}

module "ec2_bastion" {
  source = "github.com/terraform-aws-modules/terraform-aws-ec2-instance?ref=v1.9.0"

  name                        = "${var.name_prefix}-bastion"
  instance_count              = 1
  ami                         = "${data.aws_ami.amazon_linux.id}"
  instance_type               = "t2.micro"
  key_name                    = "${aws_key_pair.default.key_name}"
  subnet_id                   = "${module.vpc.public_subnets[0]}"
  associate_public_ip_address = true

  vpc_security_group_ids = [
    "${aws_security_group.ssh.id}",
    "${aws_security_group.internal.id}",
  ]

  tags = "${merge(map("Name", format("%s-bastion", var.name_prefix)), var.default_tags)}"
}

output "ec2_bastion_public_ip" {
  value = "${module.ec2_bastion.public_ip[0]}"
}
