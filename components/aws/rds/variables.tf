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

variable "identifier" { default = "rds-db" }
variable "engine" {
  type        = string
  description = <<EOF
The type of database to launch. E.g.: `aurora`, `aurora-mysql`,`aurora-postgresql`,
`mariadb`,`mysql`,`oracle-ee`,`oracle-se2`,`oracle-se1`,`oracle-se`,`postgres`,
`sqlserver-ee`,`sqlserver-se`,`sqlserver-ex`,`sqlserver-web`.
Check RDS documentation for updates to the supported list, and for details on each engine type.
EOF
}
variable "engine_version" {
  type = string
}
variable "storage_size_in_gb" {
  description = "The allocated storage value is denoted in GB"
  type        = string
  default     = "20"
}
variable "skip_final_snapshot" { default = false }
variable "admin_username" { type = string }
variable "admin_password" {
  description = "Must be 8 characters long."
  type        = string
  default     = null
}

variable "instance_class" {
  description = "Enter the desired node type. The default and cheapest option is 'db.t2.micro' @ ~$0.017/hr. Alternatively, the cost/month @ ~$12.25/mo.  (https://aws.amazon.com/rds/mysql/pricing/ )"
  type        = string
  default     = "db.t2.micro"
}

variable "jdbc_port" {
  type = string
}
variable "kms_key_id" {
  type    = string
  default = null
}
