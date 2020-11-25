
resource "aws_cloudwatch_event_rule" "daily_run_schedule" {
  for_each = var.schedules
  name = "${var.name_prefix}sched-${random_id.suffix.dec}-${
    replace(replace(replace(replace(replace(
      each.value,
    " ", ""), "(", ""), ")", ""), "*", ""), "?", "")
  }"
  description         = "Daily Execution 'run' @ ${each.value}"
  role_arn            = aws_iam_role.ecs_execution_role.arn
  schedule_expression = each.value
}

resource "aws_cloudwatch_event_target" "daily_run_task" {
  for_each = var.schedules
  rule     = aws_cloudwatch_event_rule.daily_run_schedule[each.value].name
  arn      = data.aws_ecs_cluster.ecs_cluster.arn
  role_arn = aws_iam_role.ecs_execution_role.arn
  ecs_target {
    task_definition_arn = aws_ecs_task_definition.ecs_task.arn
    task_count          = 1
    launch_type         = local.launch_type
    group               = "${var.name_prefix}ScheduledTasks"
    network_configuration {
      subnets          = local.subnets
      security_groups  = [aws_security_group.ecs_tasks_sg.id]
      assign_public_ip = true
    }
  }
}
