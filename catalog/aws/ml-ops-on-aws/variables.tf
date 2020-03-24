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

variable "s3_bucket_name" {
  description = "Extract S3 bucket name."
  type        = string
}

variable "data_folder" {
  description = "Local folder for training and validation data extracts."
  type        = string
  default     = "source/data"
}

variable "data_s3_path" {
  description = "S3 path for training and validation data extracts."
  type        = string
  default     = "data"
}

# State Machine input variables

variable "job_name" {
  description = "SageMaker Hyperparameter Tuning job name."
  type        = string
  default     = "attrition-job"
}

variable "endpoint_name" {
  description = "SageMaker inference endpoint to be created/updated (depending on whether or not the endpoint already exists)."
  type        = string
  default     = "attrition-endpoint"
}

variable "training_image" {
  description = "SageMaker model container image."
  type        = string
  default     = null
}

variable "tuning_objective" {
  description = "Hyperparameter tuning objective (minimize or maximize)."
  type        = string
  default     = "Maximize"
}

variable "tuning_metric" {
  description = "Hyperparameter tuning metric e.g. error, auc, f1."
  type        = string
  default     = "accuracy"
}

variable "create_endpoint_comparison_operator" {
  description = "Comparison operator for endpoint creation metric threshold."
  type        = string
  default     = "NumericGreaterThan"
}

variable "create_endpoint_metric_threshold" {
  description = "Threshold for creating/updating SageMaker endpoint."
  type        = number
  default     = 0.7
}

variable "max_number_training_jobs" {
  description = "Maximum number of total training jobs for hyperparameter tuning."
  type        = number
  default     = 3
}

variable "max_parallel_training_jobs" {
  description = "Maximimum number of training jobs running in parallel for hyperparameter tuning."
  type        = number
  default     = 3
}

variable "static_hyperparameters" {
  description = "Static hyperparameters."
  type        = map

  default = {
    "kfold_splits" = "5"
  }
}

variable "parameter_ranges" {
  description = "Tuning ranges for hyperparameters."
  type        = map

  default = {
    "ContinuousParameterRanges" = [
      {
        "Name"        = "eta",
        "MinValue"    = "0.1",
        "MaxValue"    = "0.5",
        "ScalingType" = "Auto"
      },
      {
        "Name"        = "min_child_weight",
        "MinValue"    = "5",
        "MaxValue"    = "100",
        "ScalingType" = "Auto"
      },
      {
        "Name"        = "subsample",
        "MinValue"    = "0.1",
        "MaxValue"    = "0.5",
        "ScalingType" = "Auto"
      },
      {
        "Name"        = "gamma",
        "MinValue"    = "0",
        "MaxValue"    = "5",
        "ScalingType" = "Auto"
      }
    ],
    "IntegerParameterRanges" = [
      {
        "Name"        = "max_depth",
        "MinValue"    = "0",
        "MaxValue"    = "10",
        "ScalingType" = "Auto"
      }
    ]
  }
}