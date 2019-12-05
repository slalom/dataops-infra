variable "name_prefix" {}
variable "region" { description = "AWS region" }
variable "aws_secrets_manager" { type = "string" }
variable "container_name" { default = "DefaultContainer" }
variable "container_image" {
  description = "e.g. [aws_account_id].dkr.ecr.[aws_region].amazonaws.com/[repo_name]"
}
variable "container_entrypoint" { default = "python" }
variable "container_run_command" { default = "bin/run.py" }
variable "app_port" { default = "8080" }
variable "vpc_id" { type = "string" }
variable "subnet_ids" { type = "list" }
variable "ecs_security_group" { type = "string" }
variable "tag_aliases" {
  default = {
    "latest"    = "prod"
    "beta"      = "beta"
    "latestdev" = "latest-dev"
  }
}

# Fargate ECS Cluster
variable "fargate_container_ram_gb" { default = "8" }
variable "fargate_container_num_cores" {
  description = "The number of vCPUs. e.g. 0.25, 0.5, 1, 2, 4"
  default     = "4"
}

# Standard ECS Cluster
variable "min_ec2_instances" { default = 0 }
variable "max_ec2_instances" { default = 3 }
variable "ec2_container_ram_gb" { default = "8" }
variable "ec2_container_num_cores" { default = "4" }
variable "ec2_instance_type" {}
variable "ecs_environment_secrets" {
  type        = "map"
  default     = {}
  description = <<EOF
Mapping of environment variable names to secret manager ARNs.
e.g. arn:aws:secretsmanager:[var.region]:[var.aws_account]:secret:prod/ECSRunner/AWS_SECRET_ACCESS_KEY
EOF
}
