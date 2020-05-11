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
variable "database_name" {
  description = "The name of the initial database to be created."
  default     = "default_db"
}
variable "identifier" {
  description = "The database name which will be used within connection strings and URLs."
  default     = "rds-db"
}
variable "instance_class" {
  description = "Enter the desired node type. The default and cheapest option is 'db.t2.micro' @ ~$0.017/hr, or ~$120/mo (https://aws.amazon.com/rds/mysql/pricing/ )"
  type        = string
  default     = "db.t2.micro"
}
variable "jdbc_port" {
  description = "Optional. Overrides the default JDBC port for incoming SQL connections."
  default     = 3306
}
variable "kms_key_id" {
  description = "Optional. The ARN for the KMS encryption key used in cluster encryption."
  type        = string
  default     = null
}
variable "mysql_version" {
  description = "Optional. The specific MySQL version to use."
  default     = "5.7.26"
}

variable "storage_size_in_gb" {
  description = "The allocated storage value is denoted in GB."
  type        = string
  default     = "20"
}
variable "skip_final_snapshot" {
  description = "If true, will allow terraform to destroy the RDS cluster without performing a final backup."
  default     = false
}
