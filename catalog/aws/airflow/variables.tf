# Common Variables:
variable "name_prefix" { type = string }
variable "environment" {
  type = object({
    vpc_id          = string
    aws_region      = list(string)
    public_subnets  = list(string)
    private_subnets = list(string)
  })
}
variable "resource_tags" { type = map(string) }

# Catalog Variables
variable "container_command" { type = string }
variable "container_image" {
  type    = string
  default = "airflow"
}
variable "container_num_cores" { default = 2 }
variable "container_ram_gb" { default = 4 }
variable "environment_vars" {
  type    = map(string)
  default = {}
}
variable "environment_secrets" {
  type    = map(string)
  default = {}
}
variable "github_repo_ref" {
  description = "The git repo reference to clone onto the airflow server"
  type        = string
  default     = null
}
