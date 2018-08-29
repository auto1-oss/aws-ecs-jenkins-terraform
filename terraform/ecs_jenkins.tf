data "template_file" "jenkins" {
  template = "${file("${path.module}/jenkins-task-definition.json")}"

  vars {
    password = "${var.jenkins_password}"
    bucket   = "${var.states_bucket}"
    config   = "${aws_s3_bucket_object.jenkins_config.key}"
  }
}

resource "aws_ecs_task_definition" "jenkins" {
  family                = "${var.name_prefix}-jenkins"
  container_definitions = "${data.template_file.jenkins.rendered}"

  # volume should point to mounted EFS
  volume {
    name      = "jenkins_home"
    host_path = "/srv/synced/jenkins_home"
  }

  volume {
    name      = "docker"
    host_path = "/var/run/docker.sock"
  }
}

resource "aws_lb_target_group" "jenkins" {
  name                 = "${var.name_prefix}-jenkins"
  port                 = 80
  protocol             = "HTTP"
  vpc_id               = "${module.vpc.vpc_id}"
  deregistration_delay = 30

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 10
    path                = "/login"
    interval            = 15
  }

  tags = "${merge(map("Name", format("%s-jenkins", var.name_prefix)), var.default_tags)}"

  depends_on = ["aws_lb_listener.web"]
}

resource "aws_lb_listener_rule" "jenkins" {
  listener_arn = "${aws_lb_listener.web.arn}"
  priority     = 1

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.jenkins.arn}"
  }

  condition {
    field  = "host-header"
    values = ["jenkins.*"]
  }
}

resource "aws_ecs_service" "jenkins-master" {
  name                               = "jenkins-master"
  cluster                            = "${aws_ecs_cluster.cluster.id}"
  task_definition                    = "${aws_ecs_task_definition.jenkins.arn}"
  desired_count                      = 1
  deployment_maximum_percent         = 100
  deployment_minimum_healthy_percent = 0
  health_check_grace_period_seconds  = 600

  load_balancer = {
    target_group_arn = "${aws_lb_target_group.jenkins.arn}"
    container_name   = "jenkins-master"
    container_port   = 8080
  }
}
