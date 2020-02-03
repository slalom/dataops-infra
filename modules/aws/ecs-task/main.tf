data "aws_region" "current" {}
data "aws_ecs_cluster" "ecs_cluster" { cluster_name = var.ecs_cluster_name }

locals {
  aws_region = var.aws_region != null ? var.aws_region : data.aws_region.current.name
  env_vars   = merge({ "AWS_DEFAULT_REGION" : local.aws_region }, var.environment_vars)
  container_secrets_str = join(",\n", [
    for k, v in var.environment_secrets :
    "{\"name\": \"${k}\", \"valueFrom\": \"${v}\"}"
  ])
  container_env_vars_str = join(",\n", [
    for k, v in local.env_vars :
    "{\"name\": \"${k}\", \"value\": \"${v}\"}"
  ])
  entrypoint_str = var.container_entrypoint == null ? "" : "\"entryPoint\": [\"${var.container_entrypoint}\"],"
  command_str    = var.container_command == null ? "" : "\"command\": [\"${var.container_command}\"],"
  network_mode   = var.use_fargate ? "awsvpc" : "bridge"
  launch_type    = var.use_fargate ? "FARGATE" : "EC2"
}

resource "aws_cloudwatch_log_group" "cw_log_group" {
  name = "${var.name_prefix}AWSLogs"
  tags = var.resource_tags
  # lifecycle { prevent_destroy = true }
}

resource "aws_ecs_task_definition" "ecs_task" {
  family                   = "${var.name_prefix}Task"
  network_mode             = local.network_mode
  requires_compatibilities = [local.launch_type]
  cpu                      = var.container_num_cores * 1024
  memory                   = var.container_ram_gb * 1024
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  tags                     = var.resource_tags
  container_definitions    = <<DEFINITION
[
  {
    "name":       "${var.container_name}",
    "image":      "${var.container_image}",
    "cpu":         ${var.container_num_cores * 1024},
    "memory":      ${var.container_ram_gb * 1024},
    ${local.entrypoint_str}
    ${local.command_str}
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group":          "${aws_cloudwatch_log_group.cw_log_group.name}",
        "awslogs-region":         "${local.aws_region}",
        "awslogs-stream-prefix":  "container-log"
      }
    },
    "networkMode":  "${local.network_mode}",
    "portMappings": [
      {
        "containerPort": ${var.app_ports[0]},
        "hostPort":      ${var.app_ports[0]},
        "protocol":      "tcp"
      }
    ],
    "environment": [
      ${local.container_env_vars_str}
    ],
    "secrets": [
      ${local.container_secrets_str}
    ]
  }
]
DEFINITION
}

resource "aws_security_group" "ecs_tasks_sg" {
  name        = "${var.name_prefix}ECSSecurityGroup"
  description = "allow inbound access on specific ports"
  vpc_id      = var.vpc_id
  tags        = var.resource_tags
  dynamic "ingress" {
    for_each = var.app_ports
    content {
      protocol    = "tcp"
      from_port   = ingress.value
      to_port     = ingress.value
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  egress {
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ecs_service" "ecs_service" {
  name            = "${var.name_prefix}ECSService"
  desired_count   = 0
  cluster         = data.aws_ecs_cluster.ecs_cluster.arn
  task_definition = aws_ecs_task_definition.ecs_task.arn
  launch_type     = local.launch_type
  network_configuration {
    subnets         = var.subnets
    security_groups = [aws_security_group.ecs_tasks_sg.id]
  }
}

resource "aws_cloudwatch_event_rule" "daily_run_schedule" {
  for_each            = var.schedules
  name_prefix         = "${var.name_prefix}ecs-task-schedule-run-"
  description         = "Daily Execution 'run' @ ${each.value}"
  schedule_expression = each.value
}

resource "aws_cloudwatch_event_target" "daily_run_task" {
  for_each = var.schedules
  # for_each   = aws_cloudwatch_event_rule.daily_run_schedule
  rule     = aws_cloudwatch_event_rule.daily_run_schedule[each.value].name
  arn      = data.aws_ecs_cluster.ecs_cluster.arn
  role_arn = aws_iam_role.ecs_task_execution_role.arn
  ecs_target {
    task_definition_arn = aws_ecs_task_definition.ecs_task.arn
    task_count          = 1
    launch_type         = var.ecs_launch_type
    group               = "${var.name_prefix}ScheduledTasks"
    network_configuration {
      subnets          = var.subnets
      security_groups  = [aws_security_group.ecs_tasks_sg.id]
      assign_public_ip = false
    }
  }
}
