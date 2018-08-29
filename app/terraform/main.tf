# Configure accordingly to ../../terraform, can not be parametrized
terraform {
  backend "s3" {
    bucket = "myterraform-states"
    key    = "apps/iplookup.tfstate"
    region = "eu-central-1"
  }

  required_version = "~> 0.11.7"
}

provider "aws" {
  region  = "${var.region}"
  version = "~> 1.30"
}

data "terraform_remote_state" "remote" {
  backend = "s3"

  config {
    region = "${var.remote_state["region"]}"
    bucket = "${var.remote_state["bucket"]}"
    key    = "${var.remote_state["key"]}"
  }
}

resource "aws_ecr_repository" "ecr" {
  name = "${var.name}"
}

resource "aws_ecs_task_definition" "task" {
  family = "${var.name}"

  container_definitions = <<DEFINITION
[
  {
    "cpu": 64,
    "memory": 32,
    "image": "${aws_ecr_repository.ecr.repository_url}:${var.version}",
    "name": "${var.name}",
    "portMappings": [
      {
        "containerPort": ${var.container_port},
        "hostPort": 0
      }
    ]
  }
]
DEFINITION
}

resource "aws_lb_target_group" "tg" {
  name                 = "${data.terraform_remote_state.remote.ecs_cluster}-${var.name}"
  port                 = 80
  protocol             = "HTTP"
  vpc_id               = "${data.terraform_remote_state.remote.vpc_id}"
  deregistration_delay = 10

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 10
    path                = "/"
    interval            = 15
  }
}

# Used to set random priority to listener rule
resource "random_id" "deploy" {
  byte_length = 2
}

resource "aws_lb_listener_rule" "rule" {
  listener_arn = "${data.terraform_remote_state.remote.lb_http_listener_arn}"
  priority     = "${random_id.deploy.dec % 50000}"

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.tg.arn}"
  }

  condition {
    field  = "host-header"
    values = ["${var.name}.*"]
  }
}

resource "aws_ecs_service" "service" {
  name                               = "${var.name}"
  cluster                            = "${data.terraform_remote_state.remote.ecs_cluster}"
  task_definition                    = "${aws_ecs_task_definition.task.arn}"
  desired_count                      = 1
  deployment_maximum_percent         = 100
  deployment_minimum_healthy_percent = 0

  load_balancer {
    target_group_arn = "${aws_lb_target_group.tg.arn}"
    container_name   = "${var.name}"
    container_port   = "${var.container_port}"
  }
}

resource "aws_route53_record" "dns" {
  zone_id = "${data.terraform_remote_state.remote.private_zone_id}"
  name    = "${var.name}"
  type    = "A"

  alias {
    name                   = "${data.terraform_remote_state.remote.lb_dns_name}"
    zone_id                = "${data.terraform_remote_state.remote.lb_zone_id}"
    evaluate_target_health = true
  }
}

# Here comes autoscaling
resource "aws_appautoscaling_target" "target" {
  resource_id        = "service/${data.terraform_remote_state.remote.ecs_cluster}/${var.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  min_capacity       = 1
  max_capacity       = 5
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "scale-up" {
  name               = "${var.name}-up"
  resource_id        = "service/${data.terraform_remote_state.remote.ecs_cluster}/${var.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = 1
    }
  }

  depends_on = ["aws_appautoscaling_target.target"]
}

resource "aws_cloudwatch_metric_alarm" "metric-up" {
  alarm_name          = "${var.name}-up"
  namespace           = "AWS/ECS"
  metric_name         = "CPUUtilization"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  period              = 60
  statistic           = "Average"
  threshold           = 60

  dimensions = {
    ClusterName = "${data.terraform_remote_state.remote.ecs_cluster}"
    ServiceName = "${var.name}"
  }

  alarm_actions = ["${aws_appautoscaling_policy.scale-up.arn}"]
}

resource "aws_appautoscaling_policy" "scale-down" {
  name               = "${var.name}-down"
  resource_id        = "service/${data.terraform_remote_state.remote.ecs_cluster}/${var.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_upper_bound = 0
      scaling_adjustment          = "-1"
    }
  }

  depends_on = ["aws_appautoscaling_target.target"]
}

resource "aws_cloudwatch_metric_alarm" "metric-down" {
  alarm_name          = "${var.name}-down"
  namespace           = "AWS/ECS"
  metric_name         = "CPUUtilization"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 1
  period              = 60
  statistic           = "Average"
  threshold           = 30

  dimensions = {
    ClusterName = "${data.terraform_remote_state.remote.ecs_cluster}"
    ServiceName = "${var.name}"
  }

  alarm_actions = ["${aws_appautoscaling_policy.scale-down.arn}"]
}
