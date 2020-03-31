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

variable "feature_store_name" {
  description = "Bucket which contains pre-transformed training data and scoring data."
  type        = string
}

variable "extracts_store_name" {
  description = "Bucket which contains transformed training and scoring data."
  type        = string
}

variable "model_store_name" {
  description = "Bucket which contains model objects."
  type        = string
}

variable "output_store_name" {
  description = "Bucket which contains batch transformation output."
  type        = string
}

variable "state_machine_definition" {
  description = "The JSON definition of the state machine to be created."
  type        = string
}

variable "lambda_functions" {
  description = "Map of function names to ARNs. Used to ensure state machine access to functions."
  type        = map(string)
}
