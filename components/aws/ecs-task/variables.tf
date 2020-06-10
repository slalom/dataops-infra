##############################################
### Standard variables for all AWS modules ###
##############################################

variable "name_prefix" {
  description = "Standard `name_prefix` module input."
  type        = string
}
variable "environment" {
  description = "Standard `environment` module input."
  type = object({
    vpc_id          = string
    aws_region      = string
    public_subnets  = list(string)
    private_subnets = list(string)
  })
}
variable "resource_tags" {
  description = "Standard `resource_tags` module input."
  type        = map(string)
}

########################################
### Custom variables for this module ###
########################################

variable "always_on" {
  description = "True to create an ECS Service with a single 'always-on' task instance."
  type        = bool
  default     = false
}
variable "admin_ports" {
  description = "A list of admin ports (to be governed by `admin_cidr`)."
  type        = list(string)
  default     = ["8080"]
}
variable "app_ports" {
  description = "A list of app ports (will be governed by `app_cidr`)."
  type        = list(string)
  default     = ["8080"]
}
variable "container_command" {
  description = "Optional. Overrides 'command' for the image."
  default     = null
}
variable "container_entrypoint" {
  description = "Optional. Overrides the 'entrypoint' for the image."
  default     = null
}
variable "container_image" {
  description = "Examples: 'python:3.8', [aws_account_id].dkr.ecr.[aws_region].amazonaws.com/[repo_name]"
  type        = string
}
variable "container_name" {
  description = "Optional. Overrides the name of the default container."
  default     = "DefaultContainer"
}
variable "container_num_cores" {
  description = "The number of CPU cores to dedicate to the container."
  default     = "4"
}
variable "container_ram_gb" {
  description = "The amount of RAM to dedicate to the container."
  default     = "8"
}
variable "ecs_cluster_name" {
  description = "The name of the ECS Cluster to use."
  type        = string
}
variable "ecs_launch_type" {
  # TODO: Replace with a condition on `use_fargate`
  description = "'FARGATE' or 'Standard'"
  default     = "FARGATE"
}
variable "environment_secrets" {
  type        = map(string)
  default     = {}
  description = <<EOF
Mapping of environment variable names to secret manager ARNs or local file secrets. Examples:
 - arn:aws:secretsmanager:[aws_region]:[aws_account]:secret:prod/ECSRunner/AWS_SECRET_ACCESS_KEY
 - path/to/file.json:MY_KEY_NAME_1
 - path/to/file.yml:MY_KEY_NAME_2
EOF
}
variable "environment_vars" {
  description = "Mapping of environment variable names to their values."
  type        = map(string)
  default     = {}
}
variable "load_balancer_arn" {
  description = "Required only if `use_load_balancer` = True. The load balancer to use for inbound traffic."
  type        = string
  default     = null
}

variable "permitted_s3_buckets" {
  description = "A list of bucket names, to which the ECS task will be granted read/write access."
  type        = list(string)
  default     = null
}
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
variable "schedules" {
  description = "A lists of scheduled execution times."
  type        = set(string)
  default     = []
}
variable "secrets_manager_kms_key_id" {
  description = "Optional. Overrides the KMS key used when storing secrets in AWS Secrets Manager."
  type        = string
  default     = null
}
variable "use_load_balancer" {
  description = "True to receive inbound traffic from the load balancer specified in `load_balancer_arn`."
  type        = bool
  default     = false
}
variable "use_fargate" {
  description = "True to use Fargate for task execution (default), False to use EC2 (classic)."
  type        = bool
  default     = true
}
variable "use_private_subnet" {
  description = <<EOF
If True, tasks will use a private subnet and will require a NAT gateway to pull the docker
image, and for any outbound traffic. If False, tasks will use a public subnet and will not
require a NAT gateway.
EOF
  type        = bool
  default     = false
}
