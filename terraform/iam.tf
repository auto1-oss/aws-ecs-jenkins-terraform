resource "aws_iam_instance_profile" "ecs_instance" {
  name = "${var.name_prefix}-ecs_instance"
  role = "${aws_iam_role.ecs_instance.name}"
}

resource "aws_iam_role" "ecs_instance" {
  name = "${var.name_prefix}-ecs_instance"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": [
          "ec2.amazonaws.com"
        ]
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

# This bucket was precreated to store this terraform states, will be reused for applications
resource "aws_iam_policy" "custom" {
  name        = "${var.name_prefix}-ecs_instance"
  description = "Custom policy for ecs_instance used for deploy"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket",
                "s3:GetObject"
            ],
            "Resource": [
                "arn:aws:s3:::${var.states_bucket}",
                "arn:aws:s3:::${var.states_bucket}/*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:PutObject"
            ],
            "Resource": [
                "arn:aws:s3:::${var.states_bucket}/apps/*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "application-autoscaling:*",
                "iam:CreateServiceLinkedRole",
                "cloudwatch:DescribeAlarms",
                "cloudwatch:PutMetricAlarm",
                "route53:GetChange"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "route53:ChangeResourceRecordSets",
                "route53:CreateHealthCheck",
                "route53:DeleteHealthCheck",
                "route53:Get*",
                "route53:List*",
                "route53:Update*"
            ],
            "Resource": [
                "arn:aws:route53:::hostedzone/${aws_route53_zone.private.zone_id}"
            ]
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "custom" {
  role       = "${aws_iam_role.ecs_instance.name}"
  policy_arn = "${aws_iam_policy.custom.arn}"
}

# Custom proper policies should be created, these are just used as example
resource "aws_iam_role_policy_attachment" "ecs_instance_ecs" {
  role       = "${aws_iam_role.ecs_instance.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerServiceFullAccess"
}

resource "aws_iam_role_policy_attachment" "ecs_instance_ecr" {
  role       = "${aws_iam_role.ecs_instance.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
}
