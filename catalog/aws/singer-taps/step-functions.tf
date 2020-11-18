
module "step_function" {
  count         = length(local.taps_specs)
  source        = "../../../components/aws/step-functions"
  name_prefix   = "${var.name_prefix}${count.index}-${local.taps_specs[count.index].name}-"
  environment   = var.environment
  resource_tags = var.resource_tags

  writeable_buckets = []
  lambda_functions  = module.triggered_lambda.function_ids
  ecs_tasks = [
    module.ecs_tap_sync_task[count.index].ecs_task_name
  ]
  state_machine_definition = <<EOF
{
  "Version": "1.0",
  "Comment": "Run Sync (ECS Fargate: ${local.taps_specs[count.index].image})",
  "TimeoutSeconds": ${var.timeout_hours * (60 * 60)},
  "StartAt": "RunTask",
  "States": {
    "RunTask": {
      "Type": "Task",
      "Resource": "arn:aws:states:::ecs:runTask.sync",
      "Parameters": {
        "LaunchType": "FARGATE",
        "Cluster": "${module.ecs_cluster.ecs_cluster_name}",
        "TaskDefinition": "${module.ecs_tap_sync_task[count.index].ecs_task_name}",
        "NetworkConfiguration": {
          "AwsvpcConfiguration": {
            "SecurityGroups": ["${module.ecs_tap_sync_task[count.index].ecs_security_group}"],
            "Subnets": ["${module.ecs_tap_sync_task[count.index].subnets[0]}"],
            "AssignPublicIp": "${var.use_private_subnet ? "DISABLED" : "ENABLED"}"
          }
        },
        "Overrides":{
          "ContainerOverrides":[]
        }
      },
      "Catch": [
        {
          "ErrorEquals": ["States.ALL"],
          "Next": "NotifyOnError"
        }
      ],
      "Retry": [
        {
          "ErrorEquals": [
            "States.TaskFailed"
          ],
          "IntervalSeconds": 10,
          "MaxAttempts": ${var.num_retries},
          "BackoffRate": 2
        }
      ],
      "Next": "NotifyOnSuccess"
    },
    "NotifyOnSuccess": {
      "Type": "Task",
      "Resource": "arn:aws:states:::lambda:invoke",
      "Parameters":{
        "FunctionName": "${module.triggered_lambda.function_ids["SuccessWebhook"]}",
        "Payload": {
            "tap_name": "${local.taps_specs[count.index].name}",
            "dashboard_url": "${local.dashboard_urls[count.index]}"
        }
      },
      "End": true
    },
    "NotifyOnError": {
      "Type": "Task",
      "Resource": "arn:aws:states:::lambda:invoke",
      "Parameters":{
        "FunctionName": "${module.triggered_lambda.function_ids["AlertsWebhook"]}",
        "Payload": {
            "tap_name": "${local.taps_specs[count.index].name}",
            "dashboard_url": "${local.dashboard_urls[count.index]}"
        }
      },
      "Next": "ExecutionFailed"
    },
    "ExecutionFailed": {
      "Type": "Fail",
      "Cause": "Failure occurred during execution.",
      "Error": "ExecutionFailed"
    }
  }
}
EOF
}
