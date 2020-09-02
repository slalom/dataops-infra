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

variable "standard_image" {
  description = <<EOF
Optional. The name of an available prebuilt bastion image to use for the container.

- Currently only `dataopstk/bastion:python-3.8` is supported (default).
- Ignored if `custom_base_image` is provided.
EOF
  type    = string
  default = "dataopstk/bastion:python-3.8"
}
variable "custom_base_image" {
  description = <<EOF
Optional. The name of a custom base image, on top of which to build a custom bastion image.

- Overrides any setting provided for `standard_image`.
- This option has additional workstation requirements, including Golang, Docker, and special docker
  config as defined here: https://infra.dataops.tk/components/aws/ecr-image/#prereqs
EOF
  type    = string
  default = null
}
variable "settings" {
  description = "Map of environment variables."
  type        = map(string)
  default     = {}
}
variable "secrets" {
  description = "Map of environment secrets."
  type        = map(string)
  default     = {}
}
variable "container_entrypoint" {
  description = "Optional. Override the docker image's entrypoint."
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
variable "aws_credentials_file" {
  description = "Path to the AWS credentials file, used to ensure that the correct credentials are used during upload of the ECR image."
  type        = string
}
