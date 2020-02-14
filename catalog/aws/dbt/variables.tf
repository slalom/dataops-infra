variable "aws_region" { default = null }
variable "vpc_id" { default = null }
variable "public_subnets" { default = null }
variable "private_subnets" { default = null }
variable "resource_tags" {
  type    = map
  default = {}
}
variable "admin_cidr" {
  type    = list
  default = []
}
variable "container_image" { default = "slalomggp/dataops" }
variable "container_entrypoint" { default = null }
variable "container_num_cores" { default = 4 }
variable "container_ram_gb" { default = 16 }
variable "dbt_project_git_repo" {
  type    = string
  default = "git+https://github.com/slalom-ggp/dataops-project-template.git"
}
variable "dbt_run_command" {
  type    = string
  default = null
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
variable "name_prefix" { type = string }
variable "scheduled_refresh_interval" {
  type        = string
  description = "A rate string, e.g. '5 minutes'. This is in addition to any other scheduled executions."
  default     = null
}
variable "scheduled_refresh_times" {
  type        = list(string)
  description = "A list of schedule strings in 6-part cron notation. For help creating cron schedule codes: https://crontab.guru"
  default     = []
}
variable "scheduled_timezone" {
  default = "PT"
}
