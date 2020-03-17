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

variable "admin_cidr" { default = [] }
variable "ec2_instance_type" {
  description = <<EOF
The instance type for the Matillion server.
EOF
  default     = "m4.4xlarge"
}
variable "warehouse_type" {
  description = "Supported options are 'snowflake' or 'redshift'"
  default     = "snowflake"
}
variable "matillion_version" {
  description = "The version of Matillion to install. To determine the latest available version, see the AWS marketplace page [here](https://aws.amazon.com/marketplace/pp/B073GRSSZD?ref_=srh_res_product_title)."
  default     = "1.42"
}
variable "scheduled_timezone" {
  description = "The timezone to use when calculating scheduled uptime. Supported timezones: PST, EST, UTC"
  default     = "PST"
}
variable "scheduled_weekday_uptime" {
  description = <<EOF
A list of time windows which the server should use for its scheduled uptime from Mondays to Fridays.
At the end of each time window, the Matillion server will automatically turn itself off to reduce cost.
EOF
  default = [
    "0600-1800",
    "0200-0330"
  ]
}
variable "scheduled_weekend_uptime" {
  description = <<EOF
A list of time windows which the server should use for its scheduled uptime on Saturdays and Sundays.
At the end of each time window, the Matillion server will automatically turn itself off to reduce cost.
EOF
  default = [
    "0200-0530"
  ]
}
variable "ec2_instance_storage_gb" { default = 100 }
variable "allow_http" { default = false }
variable "http_port" { default = 80 }
variable "https_port" { default = 443 }
variable "create_https_ssl_cert" { default = true }
