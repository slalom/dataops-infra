output "ecs_security_group" { value = "${aws_security_group.ecs_tasks_sg.id}" }
output "ecs_logging_url" {
  value = "https://${local.aws_region}.console.aws.amazon.com/cloudwatch/home?region=${local.aws_region}#logEventViewer:group=${aws_cloudwatch_log_group.cw_log_group.name}"
}
output "ecs_container_name" { value = "${var.container_name}" }
output "ecs_task_name" { value = "${aws_ecs_task_definition.ecs_task.family}" }
output "ecs_runtask_cli" {
  value = "aws ecs run-task --task-definition ${aws_ecs_task_definition.ecs_task.family} --cluster ${var.ecs_cluster_name} --launch-type ${local.launch_type} --region ${local.aws_region} ${var.use_fargate ? "--network-configuration 'awsvpcConfiguration={subnets=[${element(var.subnets, 0)}],securityGroups=[${aws_security_group.ecs_tasks_sg.id}],assignPublicIp=ENABLED}'" : ""}"
}
