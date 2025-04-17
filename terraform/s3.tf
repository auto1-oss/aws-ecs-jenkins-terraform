#
# This file is part of the auto1-oss/aws-ecs-jenkins-terraform.
#
# (c) AUTO1 Group SE https://www.auto1-group.com
#
# For the full copyright and license information, please view the LICENSE
# file that was distributed with this source code.
#

resource "aws_s3_bucket" "terraform_states" {
  bucket = "${var.states_bucket}"
  acl    = "private"

  versioning {
    enabled = true
  }

  tags = "${merge(map("Name", var.name_prefix), var.default_tags)}"
}

resource "aws_s3_bucket_object" "jenkins_config" {
  bucket = "${aws_s3_bucket.terraform_states.bucket}"
  key    = "apps/jenkins/config.yml"
  source = "jenkins-config.yml"
  etag   = "${md5(file("jenkins-config.yml"))}"
}
