variable "name_prefix" { type = string }
variable "environment" {

}
variable "identifier" { default = "rds-db" }
variable "engine" { default = "mysql" }
variable "engine_version" { default = "5.7.26" }
variable "storage_size_in_gb" {
  description = "The allocated storage value is denoted in GB"
  type        = string
  default     = "20"
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

variable "instance_class" {
  description = "Enter the desired node type. The default and cheapest option is 'db.t2.micro' @ ~$0.017/hr. Alternatively, the cost/month @ ~$12.25/mo.  (https://aws.amazon.com/rds/mysql/pricing/ )"
  type        = string
  default     = "db.t2.micro"
}

variable "jdbc_port" { default = 3306 }
variable "kms_key_id" {
  type    = string
  default = null
}
