locals {
  state_machine_json = [
    for i, tap_spec in local.taps_specs :
    <<EOF
{
  "Version": "1.0",
  "Comment": "Run Sync (ECS Fargate: ${tap_spec.image})",
  "TimeoutSeconds": ${var.timeout_hours * (60 * 60)},
  "StartAt": "RunTask",
  "States": {
    "RunTask": {
      "Type": "Task",
      "Resource": "arn:aws:states:::ecs:runTask.sync",
      "Parameters": {
        "LaunchType": "FARGATE",
        "Cluster": "${module.ecs_cluster.ecs_cluster_name}",
        "TaskDefinition": "${module.ecs_tap_sync_task[i].ecs_task_name}",
        "NetworkConfiguration": {
          "AwsvpcConfiguration": {
            "SecurityGroups": ["${module.ecs_tap_sync_task[i].ecs_security_group}"],
            "Subnets": ["${module.ecs_tap_sync_task[i].subnets[0]}"],
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
          "Next": "${var.alerts_webhook_url == null ? "ExecutionFailed" : "NotifyOnError"}"
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
      ${var.success_webhook_url == null ? <<EOF2
      "End": true
    },
EOF2
    : <<EOF2
      "Next": "NotifyOnSuccess"
    },
    "NotifyOnSuccess": {
      "Type": "Task",
      "Resource": "arn:aws:states:::lambda:invoke",
      "Parameters":{
        "FunctionName": "${module.triggered_lambda[0].function_ids["NotifyWebook"]}",
        "Payload": {
          "MESSAGE_TEXT": "${var.success_webhook_message == null ? "" : replace(var.success_webhook_message, "\n", "\\n")}",
          "WEBHOOK_URL": "${var.success_webhook_url == null ? "" : var.success_webhook_url}",
          "tap_name": "${tap_spec.name}",
          "dashboard_url": "${local.dashboard_urls[i]}"
        }
      },
      "End": true
    },
EOF2
    }
    ${var.alerts_webhook_url == null ? "" : <<EOF2
    "NotifyOnError": {
      "Type": "Task",
      "Resource": "arn:aws:states:::lambda:invoke",
      "Parameters":{
        "FunctionName": "${module.triggered_lambda[0].function_ids["NotifyWebook"]}",
        "Payload": {
            "MESSAGE_TEXT": "${var.alerts_webhook_message == null ? "" : replace(var.alerts_webhook_message, "\n", "\\n")}",
            "WEBHOOK_URL": "${var.alerts_webhook_url == null ? "" : var.alerts_webhook_url}",
            "tap_name": "${tap_spec.name}",
            "dashboard_url": "${local.dashboard_urls[i]}"
        }
      },
      "Next": "ExecutionFailed"
    },
EOF2
  }
    "ExecutionFailed": {
      "Type": "Fail",
      "Cause": "Failure occurred during execution.",
      "Error": "ExecutionFailed"
    }
  }
}
EOF
]
}

module "step_function" {
  count         = length(local.taps_specs)
  source        = "../../../components/aws/step-functions"
  name_prefix   = "${var.name_prefix}${count.index}-"
  environment   = var.environment
  resource_tags = var.resource_tags

  writeable_buckets = []
  lambda_functions  = var.success_webhook_url == null && var.success_webhook_url == null ? {} : module.triggered_lambda[0].function_ids
  ecs_tasks = [
    module.ecs_tap_sync_task[count.index].ecs_task_name
  ]
  schedules = [
    # Converts 4-digit time of day into cron. https://crontab.guru/
    for cron_expr in local.taps_specs[count.index].schedule :
    "cron(${
      tonumber(substr(cron_expr, 2, 2))
      } ${
      (24 + tonumber(substr(cron_expr, 0, 2)) - local.tz_hour_offset) % 24
    } * * ? *)"
  ]
  state_machine_definition = local.state_machine_json[count.index]
}
