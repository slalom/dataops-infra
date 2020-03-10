# Hack required to allow time for IAM execution role to propagate - customise to use desired interpreter
resource "null_resource" "delay" {
  provisioner "local-exec" {
    command     = "sleep 30"
    interpreter = ["PowerShell", "-Command"]
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
