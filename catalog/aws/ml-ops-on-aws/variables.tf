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
  description = "Local folder for training data extract."
  type        = string
  default     = "source/data"
}

variable "data_s3_path" {
  description = "S3 path for training data extract."
  type        = string
  default     = "data"
}

# State Machine input variables

variable "job_name" {
  description = "SageMaker Hyperparameter Tuning job name."
  type        = string
  default     = "hyperameter-tuning-job"
}

variable "endpoint_name" {
  description = <<EOF
SageMaker inference endpoint to be created/updated. Endpoint will be created if
it does not already exist.
EOF
  type        = string
  default     = "training-endpoint"
}

variable "training_image" {
  description = "SageMaker model container image URI from ECR repo."
  type        = string
}

variable "tuning_objective" {
  description = "Hyperparameter tuning objective ('Minimize' or 'Maximize')."
  type        = string
  default     = "Maximize"
}

variable "tuning_metric" {
  description = "Hyperparameter tuning metric, e.g. 'error', 'auc', 'f1', 'accuracy'."
  type        = string
  default     = "accuracy"
}

variable "inference_comparison_operator" {
  description = <<EOF
Comparison operator for deploying the trained SageMaker model.
Used in combination with `inference_metric_threshold`.
Examples: 'NumericGreaterThan', 'NumericLessThan', etc.
EOF
  type        = string
  default     = "NumericGreaterThan"
}

variable "inference_metric_threshold" {
  description = <<EOF
Threshold for deploying the trained SageMaker model.
Used in combination with `inference_comparison_operator`.
EOF
  type        = number
  default     = 0.7
}

variable "endpoint_or_batch_transform" {
  description = "Choose whether to create/update an inference API endpoint or do batch inference on test data."
  type        = string
  default     = "Batch Transform" # Batch Transform or Create Model Endpoint Config
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
  description = <<EOF
Map of hyperparameter names to static values, which should not be altered during hyperparameter tuning.
E.g. `{ "kfold_splits" = "5" }`
EOF
  type        = map
  default     = {}
}

variable "parameter_ranges" {
  description = <<EOF
Tuning ranges for hyperparameters.
Expects a map of one or both "ContinuousParameterRanges" and "IntegerParameterRanges".
Each item in the map should point to a list of object with the following keys:
 - Name        - name of the variable to be tuned
 - MinValue    - min value of the range
 - MaxValue    - max value of the range
 - ScalingType - 'Auto', 'Linear', 'Logarithmic', or 'ReverseLogarithmic'
EOF
  type        = map(list(object({
    Name        = string
    MinValue    = string
    MaxValue    = string
    ScalingType = string
  })))
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