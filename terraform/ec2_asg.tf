data "aws_ami" "amazon_linux_ecs" {
  most_recent = true

  filter {
    name = "name"

    values = [
      "amzn-ami-*.a-amazon-ecs-optimized",
    ]
  }

  filter {
    name = "owner-alias"

    values = [
      "amazon",
    ]
  }
}

data "template_file" "user_data" {
  template = "${file("${path.module}/user-data.sh")}"

  vars {
    ecs_cluster_name = "${aws_ecs_cluster.cluster.name}"
    efs_id           = "${aws_efs_file_system.ecs.id}"
  }
}

data "template_cloudinit_config" "user_data" {
  gzip          = false
  base64_encode = false

  part {
    content_type = "text/x-shellscript"
    content      = "${data.template_file.user_data.rendered}"
  }
}

module "asg" {
  source = "github.com/terraform-aws-modules/terraform-aws-autoscaling?ref=v2.8.0"

  name = "${var.name_prefix}-asg"

  # Launch configuration
  lc_name = "${var.name_prefix}-v1.0.0"

  image_id             = "${data.aws_ami.amazon_linux_ecs.id}"
  instance_type        = "m4.large"
  security_groups      = ["${aws_security_group.internal.id}"]
  iam_instance_profile = "${aws_iam_instance_profile.ecs_instance.name}"
  key_name             = "${aws_key_pair.default.key_name}"

  # This volume is being used by ECS optimized AMI
  # https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-ami-storage-config.html
  ebs_block_device = [
    {
      device_name           = "/dev/xvdcz"
      volume_type           = "gp2"
      volume_size           = "50"
      delete_on_termination = true
    },
  ]

  # Auto scaling group
  asg_name                  = "${var.name_prefix}-asg"
  vpc_zone_identifier       = "${module.vpc.private_subnets}"
  health_check_type         = "EC2"
  min_size                  = 1
  max_size                  = 3
  desired_capacity          = 1
  wait_for_capacity_timeout = 0
  user_data                 = "${data.template_cloudinit_config.user_data.rendered}"

  tags = [
    {
      key                 = "ECS_CLUSTER"
      value               = "${aws_ecs_cluster.cluster.name}"
      propagate_at_launch = true
    },
  ]
}

# Add 1 instance in case free resources are low
resource "aws_autoscaling_policy" "scale-up" {
  name                   = "${var.name_prefix}-up"
  autoscaling_group_name = "${module.asg.this_autoscaling_group_name}"
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 1
  cooldown               = 300
}

resource "aws_cloudwatch_metric_alarm" "metric-up" {
  alarm_name          = "${var.name_prefix}-up"
  namespace           = "AWS/ECS"
  metric_name         = "CPUReservation"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  period              = 300
  statistic           = "Average"
  threshold           = 60

  dimensions = {
    ClusterName = "${aws_ecs_cluster.cluster.name}"
  }

  alarm_actions = ["${aws_autoscaling_policy.scale-up.arn}"]
}

# remove 1 instance in case free resources are high
resource "aws_autoscaling_policy" "scale-down" {
  name                   = "${var.name_prefix}-down"
  autoscaling_group_name = "${module.asg.this_autoscaling_group_name}"
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = "-1"
  cooldown               = 300
}

resource "aws_cloudwatch_metric_alarm" "metric-down" {
  alarm_name          = "${var.name_prefix}-down"
  namespace           = "AWS/ECS"
  metric_name         = "CPUReservation"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 1
  period              = 300
  statistic           = "Average"
  threshold           = 30

  dimensions = {
    ClusterName = "${aws_ecs_cluster.cluster.name}"
  }

  alarm_actions = ["${aws_autoscaling_policy.scale-down.arn}"]
}
