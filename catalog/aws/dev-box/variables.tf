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

variable "container_image" {
  description = "Optional. Override the docker image with a custom-managed image."
  default     = null
}
variable "container_entrypoint" {
  description = "Optional. Override the docker image's entrypoint."
  default     = null
}
variable "container_command" {
  description = "Optional. Override the docker image's command."
  default     = null
}
variable "container_num_cores" {
  description = "Optional. Specify the number of cores to use in the container."
  default     = 0.5
}
variable "container_ram_gb" {
  description = "Optional. Specify the amount of RAM to be available to the container."
  default     = 1
}
variable "container_args" {
  type        = list(string)
  description = "Optional. A list of additional args to send to the container."
  default     = ["--config_file=False", "--target_config_file=False"]
}
variable "use_private_subnet" {
  description = <<EOF
If True, tasks will use a private subnet and will require a NAT gateway to pull the docker
image, and for any outbound traffic. If False, tasks will use a public subnet and will
not require a NAT gateway.
EOF
  type        = bool
  default     = false
}
variable "ssh_public_key_filepath" {
  description = "Optional. Path to a valid public key for SSH connectivity."
  type        = string
  default     = null
}
variable "ssh_private_key_filepath" {
  description = "Optional. Path to a valid public key for SSH connectivity."
  type        = string
  default     = null
}
