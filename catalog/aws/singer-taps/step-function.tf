module "step_function" {
  source        = "../../../components/aws/step-functions"
  name_prefix   = var.name_prefix
  environment   = var.environment
  resource_tags = var.resource_tags

  writeable_buckets = []
  # readonly_buckets         = []
  state_machine_definition = ""
  lambda_functions         = {}
  ecs_tasks                = {}
}
