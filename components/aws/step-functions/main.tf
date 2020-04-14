/*
* AWS Step Functions is a service provided by Amazon Web Services that makes it easier to orchestrate multiple AWS services
* to accomplish tasks. Step Functions allows you to create steps in a process where the output of one step becomes the input
* for another step.
*
*/

# Hack required to allow time for IAM execution role to propagate
locals {
  is_windows = substr(pathexpand("~"), 0, 1) == "/" ? false : true
}

resource "null_resource" "delay" {
  provisioner "local-exec" {
    command     = "sleep 60"
    interpreter = local.is_windows ? ["PowerShell", "-Command"] : []
  }
  triggers = {
    "states_exec_role" = aws_iam_role.step_functions_ml_ops_role.arn
  }
}

resource "aws_sfn_state_machine" "state_machine" {
  name     = "${lower(var.name_prefix)}state-machine"
  role_arn = aws_iam_role.step_functions_ml_ops_role.arn

  definition = var.state_machine_definition

  tags = var.resource_tags

  depends_on = [null_resource.delay]
}
