resource "aws_ecs_cluster" "cluster" {
  name = "${var.name_prefix}"
}

output "ecs_cluster" {
  value = "${aws_ecs_cluster.cluster.name}"
}
