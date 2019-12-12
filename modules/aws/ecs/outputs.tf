output "ecs_cluster_name" { value = "${aws_ecs_cluster.ecs_cluster.name}" }
output "ecs_container_name" { value = "${var.container_name}" }
output "ecs_logging_url" {
  value = "https://${var.region}.console.aws.amazon.com/cloudwatch/home?region=${var.region}#logEventViewer:group=${aws_cloudwatch_log_group.cw_log_group.name}"
}
output "ecs_fargate_task_name" { value = "${aws_ecs_task_definition.fargate_tasks["latest"].family}" }
output "ecs_standard_task_name" { value = "${aws_ecs_task_definition.standard_tasks.family}" }
output "ecs_fargate_runtask_cli" {
  value = "aws ecs run-task --task-definition ${aws_ecs_task_definition.fargate_tasks["latest"].family} --cluster ${aws_ecs_cluster.ecs_cluster.name} --launch-type FARGATE --region ${var.region} --network-configuration 'awsvpcConfiguration={subnets=[${element(var.subnet_ids, 0)}],securityGroups=[${var.ecs_security_group}],assignPublicIp=ENABLED}'"
}
output "ecs_standard_runtask_cli" {
  value = "aws ecs run-task --task-definition ${aws_ecs_task_definition.standard_tasks.family} --cluster ${aws_ecs_cluster.ecs_cluster.name} --launch-type EC2 --region ${var.region}"
}
