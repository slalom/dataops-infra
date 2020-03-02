# Hack required to allow time for IAM execution role to propagate - customise to use desired interpreter
resource "null_resource" "delay" {
  provisioner "local-exec" {
    command = "sleep 30"
    interpreter = ["PowerShell", "-Command"]
 }
  triggers = {
    "states_exec_role" = "arn:aws:iam::${var.account_id}:role/StepFunctionsWorkflowExecutionRole"
  }
}

resource "aws_sfn_state_machine" "state_machine" {
  name       = var.state_machine_name
  role_arn   = "arn:aws:iam::${var.account_id}:role/StepFunctionsWorkflowExecutionRole"

  definition = var.state_machine_definition

  tags       = var.resource_tags

  depends_on = [null_resource.delay]
}