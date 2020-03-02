output "ecs_security_group" { value = aws_security_group.ecs_tasks_sg.id }
output "ecs_logging_url" {
  value = "https://${var.environment.aws_region}.console.aws.amazon.com/cloudwatch/home?region=${var.environment.aws_region}#logEventViewer:group=${aws_cloudwatch_log_group.cw_log_group.name}"
}
output "ecs_container_name" { value = "${var.container_name}" }
output "ecs_task_name" { value = "${aws_ecs_task_definition.ecs_task.family}" }
output "ecs_runtask_cli" {
  value = "aws ecs run-task --task-definition ${aws_ecs_task_definition.ecs_task.family} --cluster ${var.ecs_cluster_name} --launch-type ${local.launch_type} --region ${var.environment.aws_region} ${var.use_fargate ? "--network-configuration awsvpcConfiguration={subnets=[${element(var.environment.public_subnets, 0)}],securityGroups=[${aws_security_group.ecs_tasks_sg.id}],assignPublicIp=ENABLED}" : ""}"
}
output "ecs_checklogs_cli" {
  value = "aws logs get-log-events --log-group-name ${aws_cloudwatch_log_group.cw_log_group.name} --limit 100"
  #  optional: --log-stream-name streamName
}
output "load_balancer_arn" { value = var.use_load_balancer ? aws_lb.alb[0].arn : null }
output "load_balancer_dns" { value = var.use_load_balancer ? aws_lb.alb[0].dns_name : null }
