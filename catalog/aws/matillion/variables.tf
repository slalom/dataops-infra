variable "admin_cidr" { default = [] }
variable "ec2_instance_type" {
  description = <<EOF
The instance type for the Matillion server.
EOF
  default     = "m4.4xlarge"
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
variable "allow_https" { default = true }
variable "http_port" { default = 80 }
variable "https_port" { default = 443 }
variable "create_https_ssl_cert" { default = true }
