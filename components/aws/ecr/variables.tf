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

variable "repository_name" {
  description = "Required. A name for the ECR respository. (Will be concatenated with `image_name`.)"
  type        = string
}
variable "image_name" {
  description = "Required. The default name for the docker image. (Will be concatenated with `repository_name`.)"
  type        = string
}
