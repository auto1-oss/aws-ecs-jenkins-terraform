resource "aws_security_group" "ssh" {
  vpc_id      = "${module.vpc.vpc_id}"
  name        = "${var.name_prefix}-ssh"
  description = "Allow incoming ssh connections"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = "${merge(map("Name", format("%s-ssh", var.name_prefix)), var.default_tags)}"
}

resource "aws_security_group" "internal" {
  vpc_id      = "${module.vpc.vpc_id}"
  name        = "${var.name_prefix}-internal"
  description = "Allow all ingress to itself, and all egress everywhere"

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = "${merge(map("Name", format("%s-internal", var.name_prefix)), var.default_tags)}"
}

resource "aws_security_group" "external" {
  vpc_id      = "${module.vpc.vpc_id}"
  name        = "${var.name_prefix}-external"
  description = "Allow web traffic from everywhere"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = "${merge(map("Name", format("%s-external", var.name_prefix)), var.default_tags)}"
}
