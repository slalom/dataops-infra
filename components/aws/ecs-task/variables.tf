##############################################
### Standard variables for all AWS modules ###
##############################################

variable "name_prefix" { type = string }
variable "environment" {
  type = object({
    vpc_id          = string
    aws_region      = string
    public_subnets  = list(string)
    private_subnets = list(string)
  })
}
variable "resource_tags" {
  type    = map(string)
  default = {}
}
########################################
### Custom variables for this module ###
########################################

variable "use_fargate" { type = bool }
variable "schedules" {
  type        = set(string)
  description = "A lists of scheduled execution times."
  default     = []
}

variable "ecs_cluster_name" { type = string }
variable "ecs_launch_type" {
  description = "'FARGATE' or 'Standard'"
  default     = "FARGATE"
}
variable "app_ports" {
  type    = list(string)
  default = ["8080"]
}
variable "admin_ports" {
  type    = list(string)
  default = ["8080"]
}
variable "container_name" { default = "DefaultContainer" }
variable "container_image" {
  description = "e.g. [aws_account_id].dkr.ecr.[aws_region].amazonaws.com/[repo_name]"
}
variable "container_entrypoint" { default = null }
variable "container_command" { default = null }
variable "container_ram_gb" { default = "8" }
variable "container_num_cores" { default = "4" }
resource "null_resource" "validate_is_fargate_config_valid" {
  count = (
    var.use_fargate == false ? 0 :
    # Check for invalid combinations of RAM and CPU for Fargate: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html
    var.container_ram_gb >= 2 * var.container_num_cores &&
    var.container_ram_gb <= 8 * var.container_num_cores &&
    var.container_ram_gb <= 30 ? 0 # OK if this check passes
    : "error"                      # Force an error if check fails
  )
}
variable "environment_secrets" {
  type        = map(string)
  default     = {}
  description = <<EOF
Mapping of environment variable names to secret manager ARNs.
e.g. arn:aws:secretsmanager:[aws_region]:[aws_account]:secret:prod/ECSRunner/AWS_SECRET_ACCESS_KEY
EOF
}
variable "environment_vars" {
  type        = map(string)
  default     = {}
  description = "Mapping of environment variable names to their values."
}
variable "load_balancer_arn" {
  type    = string
  default = null
}
variable "always_on" {
  type    = bool
  default = false
}
variable "use_load_balancer" {
  type    = bool
  default = false
}