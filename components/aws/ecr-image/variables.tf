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

variable "is_disabled" {
  description = "Switch for disabling ECR image and push."
  type        = bool
  default     = false
}

variable "repository_name" {
  description = "Name of Docker repository."
  type        = string
}

variable "build_args" {
  description = "Optional. Build arguments to use during `docker build`."
  type        = map(string)
  default     = {}
}
variable "source_image_path" {
  description = "Path to Docker image source."
  type        = string
}

variable "tag" {
  description = "Tag to use for deployed Docker image."
  type        = string
  default     = "latest"
}

variable "aws_credentials_file" {
  description = "Path to the AWS credentials file, used to ensure that the correct credentials are used during upload of the ECR image."
  type        = string
}