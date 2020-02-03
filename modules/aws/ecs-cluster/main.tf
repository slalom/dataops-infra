data "aws_availability_zones" "az_list" {}

locals {
  project_shortname = substr(var.name_prefix, 0, length(var.name_prefix) - 1)
}

resource "aws_launch_configuration" "ecs_instance_launch_config" {
  name_prefix                 = "${var.name_prefix}ECSStandardLaunchConfig"
  associate_public_ip_address = true
  ebs_optimized               = true
  enable_monitoring           = true
  instance_type               = var.ec2_instance_type
  image_id                    = data.aws_ami.ecs_linux_ami.id
  iam_instance_profile        = aws_iam_instance_profile.ecs_iam_instance_profile.id

  user_data = <<USER_DATA
#!/usr/bin/env bash
echo ECS_CLUSTER=${aws_ecs_cluster.ecs_cluster.name} >> /etc/ecs/ecs.config
USER_DATA
}

resource "aws_autoscaling_group" "ecs_asg" {
  name                 = "${var.name_prefix}ECSASG"
  availability_zones   = slice(data.aws_availability_zones.az_list.names, 0, 2)
  desired_capacity     = var.min_ec2_instances
  min_size             = var.min_ec2_instances
  max_size             = var.max_ec2_instances
  launch_configuration = aws_launch_configuration.ecs_instance_launch_config.id
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

resource "aws_ecs_cluster" "ecs_cluster" {
  name = "${var.name_prefix}ECSCluster"
  tags = var.resource_tags
}

resource "aws_iam_instance_profile" "ecs_iam_instance_profile" {
  name = "${var.name_prefix}ecs_iam_instance_profile"
  role = aws_iam_role.ecs_instance_role.id
}
