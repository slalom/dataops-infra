locals {
  cloudwatch_errors_query    = <<EOF
filter @message like /(level=CRITICAL|Error|Exception)/
| filter @message not like /WARNING/
| fields @timestamp, @message
| sort @timestamp desc
| limit 20
EOF
  cloudwatch_clean_log_query = <<EOF
filter @message not like /INFO\sUsed/
| filter @message not like /\sMaking\srequest\sto\s(GET|POST)\sendpoint/
| filter @message not like /INFO\sMaking\sGET\srequest/
| filter @message not like /INFO\sMETRIC/
| fields @timestamp, @message
| sort @timestamp desc
EOF
  dashboard_names = [
    for i, tap_spec in local.taps_specs :
    "${tap_spec.name}${i}-to-${local.target.id}-v${var.pipeline_version_number}-${var.name_prefix}-TapDashboard"
  ]
  dashboard_urls = [
    for dashboard_name in local.dashboard_names :
    "https://console.aws.amazon.com/cloudwatch/home?region=${var.environment.aws_region}#dashboards:name=${dashboard_name}"
  ]
}

resource "aws_cloudwatch_dashboard" "main" {
  count          = length(local.taps_specs)
  dashboard_name = local.dashboard_names[count.index]
  dashboard_body = <<EOF
{
  "periodOverride": "auto",
  "widgets": [
    {
      "type": "text",
      "x": 0,
      "y": 0,
      "width": 10,
      "height": 4,
      "properties": {
        "markdown": "${
  replace(replace(replace(<<EOF
## Data Pipeline (${local.taps_specs[count.index].name}-to-${local.target.id})

Additional Actions:

 - [Start New Execution (Step Function Console)](${module.step_function[count.index].state_machine_url})
 - [View Running Tasks (ECS)](https://console.aws.amazon.com/ecs/home?region=${var.environment.aws_region}#/clusters/${module.ecs_cluster.ecs_cluster_name}/tasks)
 - [View Detailed Logs (Cloudwatch)](${module.ecs_tap_sync_task[count.index].ecs_logging_url})

EOF
  , "\\", "\\\\"), "\n", "\\n"), "\"", "\\\"")
  }"
      }
    },
    {
      "type": "metric",
      "x": 0,
      "y": 4,
      "width": 10,
      "height": 4,
      "properties": {
        "metrics": [
          [
            "ECS/ContainerInsights", "TaskCount",
            "ClusterName", "${module.ecs_cluster.ecs_cluster_name}"
          ]
        ],
        "period": 60,
        "stat": "Average",
        "region": "${var.environment.aws_region}",
        "title": "Running ECS Task",
        "yAxis": {
          "left": {
            "min": 0,
            "showUnits": false
          }
        }
      }
    },
    {
      "type": "metric",
      "x": 0,
      "y": 8,
      "width": 10,
      "height": 4,
      "properties": {
        "title": "CPU and Memory Utilization",
        "metrics": [
          [ "ECS/ContainerInsights", "CpuReserved", "ClusterName", "${module.ecs_cluster.ecs_cluster_name}", { "id": "m1", "yAxis": "right", "visible": false  } ],
          [ ".", "CpuUtilized", ".", ".", { "id": "m2", "yAxis": "right" } ],
          [ ".", "MemoryReserved", ".", ".", { "id": "m3", "yAxis": "right", "visible": false  } ],
          [ ".", "MemoryUtilized", ".", ".", { "id": "m4", "yAxis": "right" } ],
          [ { "expression": "100*(m2/m1)", "label": "CpuUtilization", "id": "e1" } ],
          [ { "expression": "100*(m4/m3)", "label": "MemoryUtilization", "id": "e2" } ]
        ],
        "view": "timeSeries",
        "stacked": false,
        "region": "${var.environment.aws_region}",
        "stat": "Average",
        "period": 300,
        "yAxis": {
          "left": {
            "min": 0,
            "max": 100,
            "label": "Percentage Usage"
          },
          "right": {
            "label": "Reserved | Utilized",
            "showUnits": false,
            "min": 0
          }
        },
        "legend": {
          "position": "bottom"
        }
      }
    },
    {
      "type": "log",
      "x": 10,
      "y": 0,
      "width": 14,
      "height": 12,
      "properties": {
        "title": "Table-Level Summary",
        "query": "SOURCE '${module.ecs_tap_sync_task[count.index].cloudwatch_log_group_name}' | ${
  replace(replace(replace(<<EOF
filter @message like /sync of table/
| parse @message "sync of table '*' from '${local.taps_specs[count.index].name}'" as tablename
| parse @message " (* elapsed)" as elapsed
| fields @message
| sort tablename desc, @timestamp desc
EOF
  , "\\", "\\\\"), "\n", "\\n"), "\"", "\\\"")
  }",
        "region": "${var.environment.aws_region}",
        "stacked": "false",
        "view": "table"
      }
    },
    {
      "type": "log",
      "x": 0,
      "y": 10,
      "width": 24,
      "height": 3,
      "properties": {
        "title": "Fatal Errors",
        "query": "SOURCE '${module.ecs_tap_sync_task[count.index].cloudwatch_log_group_name}' | ${
  replace(replace(replace(local.cloudwatch_errors_query, "\\", "\\\\"), "\n", "\\n"), "\"", "\\\"")
  }",
        "region": "${var.environment.aws_region}",
        "stacked": "false",
        "view": "table"
      }
    },
    {
      "type": "log",
      "x": 0,
      "y": 13,
      "width": 24,
      "height": 12,
      "properties": {
        "title": "Detailed Logs",
        "query": "SOURCE '${module.ecs_tap_sync_task[count.index].cloudwatch_log_group_name}' | ${
  replace(replace(replace(local.cloudwatch_clean_log_query, "\\", "\\\\"), "\n", "\\n"), "\"", "\\\"")
}",
        "region": "${var.environment.aws_region}",
        "stacked": "false",
        "view": "table"
      }
    }
  ]
}
EOF
}
