output "ecr_url" {
  value = "${aws_ecr_repository.ecr.repository_url}"
}

output "application_endpoint" {
  value = "http://${var.name}.${data.terraform_remote_state.remote.private_zone_name}"
}
