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

variable "admin_username" {
  description = "The initial admin username."
  type        = string
}
variable "admin_password" {
  description = "The initial admin password. Must be 8 characters long."
  type        = string
  default     = null
}
variable "engine" {
  description = <<EOF
The type of database to launch. E.g.: `aurora`, `aurora-mysql`,`aurora-postgresql`,
`mariadb`,`mysql`,`oracle-ee`,`oracle-se2`,`oracle-se1`,`oracle-se`,`postgres`,
`sqlserver-ee`,`sqlserver-se`,`sqlserver-ex`,`sqlserver-web`.
Check RDS documentation for updates to the supported list, and for details on each engine type.
EOF
  type        = string
}
variable "engine_version" {
  description = "When paired with `engine`, specifies the version of the database engine to deploy."
  type        = string
}
variable "identifier" {
  description = "The endpoint id which will be used within connection strings and URLs."
  default     = "rds-db"
}
variable "database_name" {
  description = "The name of the initial database to be created."
  default     = "default_db"
}
variable "whitelist_terraform_ip" {
  description = "True to allow the terraform user to connect to the DB instance."
  type        = bool
  default     = true
}
variable "instance_class" {
  description = "Enter the desired node type. The default and cheapest option is 'db.t2.micro' @ ~$0.017/hr, or ~$120/mo (https://aws.amazon.com/rds/mysql/pricing/ )"
  type        = string
  default     = "db.t2.micro"
}
variable "jdbc_port" {
  description = "Optional. Overrides the default JDBC port for incoming SQL connections."
  type        = string
}
variable "kms_key_id" {
  description = "Optional. The ARN for the KMS encryption key used in cluster encryption."
  type        = string
  default     = null
}
variable "skip_final_snapshot" {
  description = "If true, will allow terraform to destroy the RDS cluster without performing a final backup."
  default     = false
}
variable "storage_size_in_gb" {
  description = "The allocated storage value is denoted in GB"
  type        = string
  default     = "20"
}
