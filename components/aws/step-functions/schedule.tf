
resource "aws_cloudwatch_event_rule" "daily_run_schedule" {
  for_each = var.schedules
  name = "${var.name_prefix}sched-${random_id.suffix.dec}-${
    replace(replace(replace(replace(replace(
      each.value,
    " ", ""), "(", ""), ")", ""), "*", ""), "?", "")
  }"
  description         = "Daily Execution 'run' @ ${each.value}"
  role_arn            = aws_iam_role.cloudwatch_invoke_role.arn
  schedule_expression = each.value
}

resource "aws_cloudwatch_event_target" "daily_run_task" {
  for_each = var.schedules
  rule     = aws_cloudwatch_event_rule.daily_run_schedule[each.value].name
  arn      = aws_sfn_state_machine.state_machine.arn
  role_arn = aws_iam_role.cloudwatch_invoke_role.arn
}
