output "cloudwatch_log_group_name" {
  description = "Name of Cloudwatch log group used for this task."
  value       = aws_cloudwatch_log_group.cw_log_group.name
}
output "ecs_checklogs_cli" {
  description = "Command-ling string used to print Cloudwatch logs locally."
  value       = "aws logs get-log-events --log-group-name ${aws_cloudwatch_log_group.cw_log_group.name} --limit 100"
  #  optional: --log-stream-name streamName
}
output "ecs_container_name" {
  description = "The name of the task's primary container."
  value       = var.container_name
}
output "ecs_task_execution_role" {
  description = "An IAM role which has access to execute the ECS Task."
  value       = aws_iam_role.ecs_execution_role.name
}
output "ecs_logging_url" {
  description = "Link to Cloudwatch logs for this task."
  value       = "https://${var.environment.aws_region}.console.aws.amazon.com/cloudwatch/home?region=${var.environment.aws_region}#logEventViewer:group=${aws_cloudwatch_log_group.cw_log_group.name}"
}
output "ecs_runtask_cli" {
  description = "Command-line string used to trigger on-demand execution of the Task."
  value = (
    "aws ecs run-task --task-definition ${
      aws_ecs_task_definition.ecs_task.family
      } --cluster ${
      var.ecs_cluster_name
      } --launch-type ${
      local.launch_type
      } --region ${
      var.environment.aws_region
      } ${
      !var.use_fargate ? "" :
      "--network-configuration awsvpcConfiguration={subnets=[${element(local.subnets, 0)}],securityGroups=[${aws_security_group.ecs_tasks_sg.id}]${var.use_private_subnet ? "" : ",assignPublicIp=ENABLED"}}"
    }"
  )
}
output "ecs_task_name" {
  description = "The name of the ECS task."
  value       = aws_ecs_task_definition.ecs_task.family
}
output "ecs_security_group" {
  description = "The name of the EC2 security group used by ECS."
  value       = aws_security_group.ecs_tasks_sg.id
}
output "load_balancer_arn" {
  description = "The unique ID (ARN) of the load balancer (if applicable)."
  value       = var.use_load_balancer ? aws_lb.alb[0].arn : null
}
output "load_balancer_dns" {
  description = "The DNS of the load balancer (if applicable)."
  value       = var.use_load_balancer ? aws_lb.alb[0].dns_name : null
}
output "subnets" {
  description = "A list of subnets used for task execution."
  value       = local.subnets
}
