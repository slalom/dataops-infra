data "aws_availability_zones" "myAZs" {}

locals {
  project_shortname = substr(var.name_prefix, 0, length(var.name_prefix) - 1)
  container_secrets_str = join(",\n", [
    for k, v in var.ecs_environment_secrets :
    "{\"name\": \"${k}\", \"valueFrom\": \"${v}\"}"
  ])
}

resource "aws_cloudwatch_log_group" "myCWLogGroup" {
  name = "${var.name_prefix}AWSLogs"
  tags = { project = local.project_shortname }
  # lifecycle { prevent_destroy = true }
}

module "aws_iam" {
  source      = "../aws-iam"
  name_prefix = "${var.name_prefix}Fargate-"
}

data "aws_ami" "ecs_linux_ami" {
  # https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-optimized_AMI.html
  owners      = ["amazon"] # AWS
  most_recent = true
  filter {
    name = "name"
    values = [
      "*ecs*optimized*",
      "*amazon-linux-2*"
    ]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
  # filter {
  #   name   = "virtualization-type"
  #   values = ["hvm"]
  # }
  # filter {
  #   name   = "root-device-type"
  #   values = ["ebs"]
  # }
}

resource "aws_ecs_cluster" "myECSCluster" {
  name = "${var.name_prefix}ECSCluster"
  tags = { project = local.project_shortname }
}
resource "aws_iam_instance_profile" "ecs_iam_instance_profile" {
  name = "${var.name_prefix}ecs_iam_instance_profile"
  role = module.aws_iam.ecs_instance_role
}

resource "aws_launch_configuration" "myEcsInstanceLaunchConfig" {
  name_prefix                 = "${var.name_prefix}ECSStandardLaunchConfig"
  associate_public_ip_address = true
  ebs_optimized               = true
  enable_monitoring           = true
  instance_type               = var.ec2_instance_type
  image_id                    = data.aws_ami.ecs_linux_ami.id
  iam_instance_profile        = aws_iam_instance_profile.ecs_iam_instance_profile.id

  user_data = <<USER_DATA
#!/usr/bin/env bash
echo ECS_CLUSTER=${aws_ecs_cluster.myECSCluster.name} >> /etc/ecs/ecs.config
USER_DATA
}

resource "aws_security_group" "ecs_tasks_sg" {
  name        = "${var.name_prefix}ECSSecurityGroup"
  description = "allow inbound access on specific ports"
  vpc_id      = var.vpc_id
  tags        = { project = local.project_shortname }
  ingress {
    protocol    = "tcp"
    from_port   = var.app_port
    to_port     = var.app_port
    cidr_blocks = ["0.0.0.0/0"]
    # security_groups = ["${aws_security_group.lb.id}"]
  }
  egress {
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_autoscaling_group" "myEcsAsg" {
  name                 = "${var.name_prefix}ECSASG"
  availability_zones   = slice(data.aws_availability_zones.myAZs.names, 0, 2)
  desired_capacity     = var.min_ec2_instances
  min_size             = var.min_ec2_instances
  max_size             = var.max_ec2_instances
  launch_configuration = aws_launch_configuration.myEcsInstanceLaunchConfig.id
}

resource "aws_ecs_service" "myFargateECSService" {
  for_each = var.tag_aliases

  name            = "${var.name_prefix}ECSServiceOnFargate-${each.key}"
  desired_count   = 0
  cluster         = aws_ecs_cluster.myECSCluster.id
  task_definition = aws_ecs_task_definition.myFargateTask[each.key].arn
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = "${var.subnet_ids}"
    security_groups = ["${var.ecs_security_group}"]
  }
  # load_balancer {
  #   target_group_arn = "${aws_alb_target_group.app.id}"
  #   container_name   = "app"
  #   container_port   = "${var.app_port}"
  # }
  # depends_on = [
  #   "aws_alb_listener.front_end",
  # ]
}

resource "aws_ecs_service" "myStandardECSService" {
  name            = "${var.name_prefix}ECSServiceOnEC2"
  desired_count   = 0
  cluster         = aws_ecs_cluster.myECSCluster.id
  task_definition = aws_ecs_task_definition.myECSStandardTask.arn
  launch_type     = "EC2"
}

resource "aws_ecs_task_definition" "myFargateTask" {
  for_each = var.tag_aliases

  family                   = "${var.name_prefix}ECSFargateTask-${each.key}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.fargate_container_num_cores * 1024
  memory                   = var.fargate_container_ram_gb * 1024
  execution_role_arn       = module.aws_iam.ecs_task_execution_role_arn
  tags                     = { project = local.project_shortname }

  container_definitions = <<DEFINITION
[
  {
    "name":       "${var.container_name}",
    "image":      "${var.container_image}:${each.value}",
    "cpu":         ${var.fargate_container_num_cores * 1024},
    "memory":      ${var.fargate_container_ram_gb * 1024},
    "entryPoint": ["${var.container_entrypoint}"],
    "command":    ["${var.container_run_command}"],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group":          "${aws_cloudwatch_log_group.myCWLogGroup.name}",
        "awslogs-region":         "${var.region}",
        "awslogs-stream-prefix":  "container-log"
      }
    },
    "networkMode":  "awsvpc",
    "portMappings": [
      {
        "containerPort": ${var.app_port},
        "hostPort":      ${var.app_port},
        "protocol":      "tcp"
      }
    ],
    "environment": [
      {
        "name":  "AWS_DEFAULT_REGION",
        "value": "${var.region}"
      }
    ],
    "secrets": [
      ${local.container_secrets_str}
    ]
  }
]
DEFINITION
}

resource "aws_ecs_task_definition" "myECSStandardTask" {
  family                   = "${var.name_prefix}ECSStandardTask"
  network_mode             = "bridge"
  requires_compatibilities = ["EC2"]
  cpu                      = var.ec2_container_num_cores * 1024
  memory                   = var.ec2_container_ram_gb * 1024
  execution_role_arn       = module.aws_iam.ecs_task_execution_role_arn
  tags                     = { project = local.project_shortname }
  container_definitions    = <<DEFINITION
[
  {
    "name":         "${var.name_prefix}Container",
    "image":        "${var.container_image}",
    "cpu":           ${var.ec2_container_num_cores * 1024},
    "memory":        ${var.ec2_container_ram_gb * 1024},
    "entryPoint":   ["${var.container_entrypoint}"],
    "command":      ["${var.container_run_command}"],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group":         "${aws_cloudwatch_log_group.myCWLogGroup.name}",
        "awslogs-region":        "${var.region}",
        "awslogs-stream-prefix": "container-log"
      }
    },
    "environment": [
      {
        "name":  "AWS_DEFAULT_REGION",
        "value": "${var.region}"
      }
    ],
    "secrets": [
      ${local.container_secrets_str}
    ]
  }
]
DEFINITION
}
