##############################################
### Standard variables for all AWS modules ###
##############################################

variable "name_prefix" {
  description = "Standard `name_prefix` module input. (Prefix counts towards 64-character max length for certain resource types.)"
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

variable "writeable_buckets" {
  description = "Buckets which should be granted write access."
  type        = list(string)
  default     = []
}

# variable "readonly_buckets" {
#   description = "Buckets which should be granted read-only access."
#   type        = list(string)
#   default     = []
# }

variable "state_machine_definition" {
  description = "The JSON definition of the state machine to be created."
  type        = string
}

variable "lambda_functions" {
  description = "Map of function names to ARNs. Used to ensure state machine access to functions."
  type        = map(string)
  default     = {}
}

variable "ecs_tasks" {
  description = "List of ECS tasks, to ensure state machine access permissions."
  type        = list(string)
  default     = []
}

variable "schedules" {
  description = "A lists of scheduled execution times."
  type        = set(string)
  default     = []
}
