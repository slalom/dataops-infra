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

variable "admin_cidr" {
  description = "Optional. The range of IP addresses which should be able to access the DBT instance. Defaults to the local user's current IP."
  type        = list
  default     = []
}
variable "container_image" {
  description = "Optional. A docker image to override the default image."
  default     = "slalomggp/dataops"
}
variable "container_entrypoint" {
  description = "Optional. Overrides the docker image entrypoint."
  default     = null
}
variable "container_num_cores" {
  description = "Optional. Overrides the number of CPU cores used."
  default     = 4
}
variable "container_ram_gb" {
  description = "Optional. Overrides the RAM used (in GB)."
  default     = 16
}
variable "dbt_project_git_repo" {
  description = "Optional. A git repo to download to the local image which contains DBT transforms information."
  type        = string
  default     = "git+https://github.com/slalom-ggp/dataops-project-template.git"
}
variable "dbt_run_command" {
  description = "Optional. The default command to run when executing DBT."
  type        = string
  default     = null
}
variable "environment_secrets" {
  description = <<EOF
Mapping of environment variable names to secret manager ARNs.
e.g. arn:aws:secretsmanager:[aws_region]:[aws_account]:secret:prod/ECSRunner/AWS_SECRET_ACCESS_KEY
EOF
  type        = map(string)
  default     = {}
}
variable "environment_vars" {
  description = "Mapping of environment variable names to their values."
  type        = map(string)
  default     = {}
}
variable "scheduled_refresh_interval" {
  description = "A rate string, e.g. '5 minutes'. This is in addition to any other scheduled executions."
  type        = string
  default     = null
}
variable "scheduled_refresh_times" {
  description = "A list of schedule strings in 6-part cron notation. For help creating cron schedule codes: https://crontab.guru"
  type        = list(string)
  default     = []
}
variable "scheduled_timezone" {
  description = "The timezone code with which to evaluate execution schedule(s)."
  default     = "PT"
}
