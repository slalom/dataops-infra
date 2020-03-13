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

variable "source_code_folder" { type = string }
variable "source_code_s3_bucket" { type = string }
variable "source_code_s3_path" {
  type    = string
  default = "code/taps"
}
variable "taps" {
  type = list(object({
    id       = string
    settings = map(string)
    secrets  = map(string)
  }))
}
variable "target" {
  type = object({
    id       = string
    settings = map(string)
    secrets  = map(string)
  })
  default = {
    id = "s3-csv"
    settings = {
      s3_key_prefix = "data/raw/{tap}/{table}/{version}/"
    }
    secrets = {}
  }
}
variable "scheduled_sync_times" {
  type        = list(string)
  description = "A list of schedule strings in 4 digit format: HHMM"
  default     = []
}
variable "scheduled_timezone" {
  default = "PT"
}
variable "container_image" { default = null }
variable "container_entrypoint" { default = null }
variable "container_command" { default = null }
variable "container_num_cores" { default = 0.5 }
variable "container_ram_gb" { default = 1 }
