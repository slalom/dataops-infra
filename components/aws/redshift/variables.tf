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

variable "admin_password" {
  description = "The initial admin password. Must be 8 characters long."
  type        = string
  default     = null
}
variable "database_name" {
  description = "The name of the initial Redshift database to be created."
  default     = "redshift_db"
}
variable "elastic_ip" {
  description = "Optional. An Elastic IP endpoint which will be used to for routing incoming traffic."
  type        = string
  default     = null
}
variable "node_type" {
  description = "Enter the desired node type. The default and cheapest option is 'dc2.large' @ ~$0.25/hr, ~$180/mo (https://aws.amazon.com/redshift/pricing/)"
  type        = string
  default     = "dc2.large"
}
variable "num_nodes" {
  description = "Optional (default=1). The number of Redshift nodes to use."
  type        = number
  default     = 1
}
variable "jdbc_port" {
  description = "Optional. Overrides the default JDBC port for incoming SQL connections."
  default     = 5439
}
variable "kms_key_id" {
  description = "Optional. The ARN for the KMS encryption key used in cluster encryption."
  type        = string
  default     = null
}
variable "s3_logging_bucket" {
  description = "Optional. An S3 bucket to use for log collection."
  type        = string
  default     = null
}
variable "s3_logging_path" {
  description = "Required if `s3_logging_bucket` is set. The path within the S3 bucket to use for log storage."
  type        = string
  default     = null
}
variable "skip_final_snapshot" {
  description = "If true, will allow terraform to destroy the RDS cluster without performing a final backup."
  default     = false
}
