
module "step_function" {
  #source       = "git::https://github.com/slalom-ggp/dataops-infra.git//catalog/aws/data-lake?ref=master"
  source        = "../../../components/aws/step-functions"
  name_prefix   = var.name_prefix
  environment   = var.environment
  resource_tags = var.resource_tags

  writeable_buckets = []
  lambda_functions  = {}
  ecs_tasks = [
    module.ecs_tap_sync_task.ecs_task_name
  ]
  state_machine_definition = <<EOF
{
  "Version": "1.0",
  "Comment": "Run Sync (ECS Fargate: ${local.container_image})",
  "TimeoutSeconds": ${var.timeout_hours * (60 * 60)},
  "StartAt": "RunTask",
  "States": {
    "RunTask": {
      "Type": "Task",
      "Resource": "arn:aws:states:::ecs:runTask.sync",
      "Parameters": {
        "LaunchType": "FARGATE",
        "Cluster": "${module.ecs_cluster.ecs_cluster_name}",
        "TaskDefinition": "${module.ecs_tap_sync_task.ecs_task_name}",
        "NetworkConfiguration": {
          "AwsvpcConfiguration": {
            "SecurityGroups": ["${module.ecs_tap_sync_task.ecs_security_group}"],
            "Subnets": ["${module.ecs_tap_sync_task.subnets[0]}"],
            "AssignPublicIp": "${var.use_private_subnet ? "DISABLED" : "ENABLED"}"
          }
        },
        "Overrides":{
          "ContainerOverrides":[]
        }
      },
      "Retry": [
        {
          "ErrorEquals": [
            "States.TaskFailed"
          ],
          "IntervalSeconds": 10,
          "MaxAttempts": ${var.num_retries + 1},
          "BackoffRate": 2
        }
      ],
      "End": true
    }
  }
}
EOF
}
