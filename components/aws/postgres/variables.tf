variable "name_prefix" { type = string }
variable "environment" {

}
variable "identifier" { default = "rds-postgres-db" }
variable "engine" { default = "postgres" }
variable "engine_version" { default = "11.5" }
variable "allocated_storage" {
  description = "The allocated storage value is denoted in GB"
  type        = string
  default     = "10"
}
variable "resource_tags" {
  type    = map
  default = {}
}
variable "skip_final_snapshot" { default = false }
variable "admin_username" { type = string }
variable "admin_password" {
  description = "Must be 8 characters long."
  type        = string
  default     = null
}
variable "elastic_ip" {
  type    = string
  default = null
}
variable "instance_class" {
  description = "Enter the desired node type. The default and cheapest option is 'db.t2.micro' @ ~$0.017/hr  (https://aws.amazon.com/rds/mysql/pricing/ )"
  type        = string
  default     = "db.t2.micro"
}

variable "jdbc_port" { default = 5432 }
variable "kms_key_id" {
  type    = string
  default = null
}
variable "s3_logging_bucket" {
  type    = string
  default = null
}
variable "s3_logging_path" {
  type    = string
  default = null
}
