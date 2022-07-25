/*
* ECS, or EC2 Container Service, is able to run docker containers natively in AWS cloud. While the module can support classic EC2-based and Fargate,
* features, this module generally prefers "ECS Fargete", which allows dynamic launching of docker containers with no always-on cost and no servers
* to manage or pay for when tasks are not running.
*
* Use in combination with the `ECS-Cluster` component.
*/

# Default AWS Region
data "aws_region" "default" {}

data "http" "icanhazip" {
  count = var.whitelist_terraform_ip ? 1 : 0
  url   = "https://ipv4.icanhazip.com"
}

data "aws_ecs_cluster" "ecs_cluster" {
  cluster_name = var.ecs_cluster_name
}

resource "random_id" "suffix" {
  byte_length = 2
}

locals {
  env_vars = merge(
    {
      "AWS_DEFAULT_REGION" : var.environment.aws_region,
      "DETECT_HOSTNAME" : "true"
    },
    var.environment_vars
  )
  container_secrets_str = join(",\n", sort([
    for k, v in module.secrets.secrets_ids :
    "{\"name\": \"${k}\", \"valueFrom\": \"${v}\"}"
  ]))
  container_env_vars_str = join(",\n", sort([
    for k, v in local.env_vars :
    "{\"name\": \"${k}\", \"value\": \"${v}\"}"
  ]))
  entrypoint_str = var.container_entrypoint == null ? "" : "\"entryPoint\": [\"${var.container_entrypoint}\"],"
  command_str    = var.container_command == null ? "" : "\"command\": [\"${replace(replace(var.container_command, "\"", "\\\""), " ", "\", \"")}\"],"
  network_mode   = var.use_fargate ? "awsvpc" : "bridge"
  launch_type    = var.use_fargate ? "FARGATE" : "EC2"
  subnets        = var.use_private_subnet ? var.environment.private_subnets : var.environment.public_subnets

  tf_admin_ip_cidr = var.whitelist_terraform_ip ? ["${chomp(data.http.icanhazip[0].body)}/32"] : []
  admin_cidr       = flatten([coalesce(var.admin_cidr, []), local.tf_admin_ip_cidr])
  app_cidr         = flatten([coalesce(var.app_cidr, []), local.tf_admin_ip_cidr])
}

module "secrets" {
  source        = "../secrets-manager"
  name_prefix   = var.name_prefix
  environment   = var.environment
  resource_tags = var.resource_tags
  secrets_map   = var.environment_secrets
  kms_key_id    = var.secrets_manager_kms_key_id
}

resource "aws_cloudwatch_log_group" "cw_log_group" {
  name = "${var.name_prefix}AWSLogs-${random_id.suffix.dec}"
  tags = var.resource_tags
  # lifecycle { prevent_destroy = true }
}

resource "aws_ecs_task_definition" "ecs_task" {
  family                   = "${var.name_prefix}Task-${random_id.suffix.dec}"
  network_mode             = local.network_mode
  requires_compatibilities = [local.launch_type]
  cpu                      = var.container_num_cores * 1024
  memory                   = var.container_ram_gb * 1024
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn
  tags                     = var.resource_tags
  container_definitions = <<DEFINITION
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
        "awslogs-region":         "${var.environment.aws_region}",
        "awslogs-stream-prefix":  "container-log"
      }
    },
    "portMappings": [
      ${join(",\n", [for p in distinct(flatten([coalesce(var.app_ports, []), coalesce(var.admin_ports, [])])) : <<EOF2
      {
        "containerPort": ${p},
        "hostPort":      ${p},
        "protocol":      "tcp"
      }
EOF2
])}
    ],
    "environment": [
      ${local.container_env_vars_str}
    ],
    "secrets": [
      ${local.container_secrets_str}
    ],
    "mountPoints": [],
    "volumesFrom": [],
    "essential" : true
  }
]
DEFINITION
}

resource "aws_security_group" "ecs_tasks_sg" {
  name        = "${var.name_prefix}ECSSecurityGroup-${random_id.suffix.dec}"
  description = "allow inbound access on specific ports, outbound on all ports"
  vpc_id      = var.environment.vpc_id
  tags        = var.resource_tags
  dynamic "ingress" {
    for_each = var.app_ports
    content {
      protocol    = "tcp"
      from_port   = ingress.value
      to_port     = ingress.value
      cidr_blocks = local.app_cidr
    }
  }
  dynamic "ingress" {
    for_each = var.admin_ports
    content {
      protocol    = "tcp"
      from_port   = ingress.value
      to_port     = ingress.value
      cidr_blocks = local.admin_cidr
    }
  }
  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ecs_service" "ecs_always_on_service" {
  count           = var.always_on ? 1 : 0
  name            = "${var.name_prefix}ECSService-${random_id.suffix.dec}"
  desired_count   = 1
  cluster         = data.aws_ecs_cluster.ecs_cluster.arn
  task_definition = aws_ecs_task_definition.ecs_task.arn
  launch_type     = local.launch_type
  # iam_role        = aws_iam_role.ecs_execution_role.name
  depends_on = [aws_lb.alb]
  network_configuration {
    subnets          = local.subnets
    security_groups  = [aws_security_group.ecs_tasks_sg.id]
    assign_public_ip = true
  }
  dynamic "load_balancer" {
    for_each = var.use_load_balancer ? toset(var.app_ports) : []
    content {
      target_group_arn = var.use_load_balancer ? aws_lb_target_group.alb_target_group[load_balancer.value].arn : null
      container_name   = var.container_name
      container_port   = load_balancer.value
      # container_name = var.use_load_balancer ? var.container_name : null
      # container_port = var.use_load_balancer ? var.admin_ports["WebPortal"] : null
    }
  }
}

# Clouwatch Group For Kinesis Logging
resource "aws_cloudwatch_log_group" "kinesis_firehose_stream_logging_group" {
  count = var.singer_metrics_flag ? 1 : 0 
  name  = "/aws/kinesisfirehose/${var.name_prefix}"
}

# Cloudwatch Stream For Kinesis Logging
resource "aws_cloudwatch_log_stream" "kinesis_firehose_stream_logging_stream" {
  count          = var.singer_metrics_flag ? 1 : 0 
  log_group_name = aws_cloudwatch_log_group.kinesis_firehose_stream_logging_group[0].name
  name           = "S3Delivery"
}

# Kinesis Firehose Delivery Stream
resource "aws_kinesis_firehose_delivery_stream" "kinesis_firehose_stream" {
  count       = var.singer_metrics_flag ? 1 : 0 
  name        = "${var.name_prefix}-Tap-SM-FirehoseStream-Task"
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn       = aws_iam_role.kinesis_firehose_stream_role.arn
    bucket_arn     = var.logging_bucket_arn
    prefix         = var.bucket_subdirectory
    processing_configuration {
      enabled = true

      processors {
        type = "Lambda"
        parameters {
            parameter_name  = "LambdaArn"
            parameter_value = "${aws_lambda_function.lambda_kinesis_firehose_data_transformation.arn}:$LATEST"
        }
        parameters {
            parameter_name  = "BufferSizeInMBs"
            parameter_value = 1
          }
        parameters {
            parameter_name  = "BufferIntervalInSeconds"
            parameter_value = 60
        }
      }
    }
    cloudwatch_logging_options {
      enabled         = true
      log_group_name  = "${aws_cloudwatch_log_group.kinesis_firehose_stream_logging_group.name}"
      log_stream_name = "${aws_cloudwatch_log_stream.kinesis_firehose_stream_logging_stream.name}"
    }
  }
}

# File pointer
data "archive_file" "kinesis_firehose_data_transformation" {
  type        = "zip"
  source_file = "${path.module}/functions/index.js"
  output_path = "${path.module}/functions/index.zip"
}

# Lambda Function
resource "aws_lambda_function" "lambda_kinesis_firehose_data_transformation" {
  count            = var.singer_metrics_flag ? 1 : 0 
  filename         = data.archive_file.kinesis_firehose_data_transformation.output_path
  function_name    = "${var.name_prefix}_Index"
  role             = aws_iam_role.lambda.arn
  handler          = "index.handler"
  source_code_hash = data.archive_file.kinesis_firehose_data_transformation.output_base64sha256
  runtime          = "nodejs12.x"
  timeout          = 60
}

# Subscription Filter
resource "aws_cloudwatch_log_subscription_filter" "cloudwatch_subscription_filter" {
  count           = var.singer_metrics_flag ? 1 : 0 
  name            = "${var.name_prefix}-Tap-SM-SubscriptionFilter-Task"
  log_group_name  = aws_cloudwatch_log_group.cw_log_group.name
  filter_pattern  = ""
  destination_arn = aws_kinesis_firehose_delivery_stream.kinesis_firehose_stream.arn
  distribution    = "ByLogStream"
  role_arn        = aws_iam_role.cloudwatch_logs_role.arn
}
