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

variable "feature_store_override" {
  description = "Optionally, you can override the default feature store bucket with a bucket that already exists."
  type        = string
  default     = null
}

variable "script_path" {
  description = "Local path for Glue Python script."
  type        = string
  default     = "source/scripts/transform.py"
}

variable "whl_path" {
  description = "Local path for Glue Python .whl file."
  type        = string
  default     = "source/scripts/python/pandasmodule-0.1-py3-none-any.whl"
}

variable "train_local_path" {
  description = "Local path for training data."
  type        = string
  default     = "source/data/train.csv"
}

variable "score_local_path" {
  description = "Local path for scoring data. Set to null for endpoint inference"
  type        = string
  default     = "source/data/score.csv"
}

# State Machine input variables

variable "job_name" {
  description = "Name prefix given to SageMaker model and training/tuning jobs (18 characters or less)."
  type        = string
}

variable "endpoint_name" {
  description = <<EOF
SageMaker inference endpoint to be created/updated. Endpoint will be created if
it does not already exist.
EOF
  type        = string
  default     = "training-endpoint"
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

variable "batch_transform_instance_count" {
  description = "Number of batch transformation instances."
  type        = number
  default     = 1
}

variable "batch_transform_instance_type" {
  description = "Instance type for batch inference."
  type        = string
  default     = "ml.m4.xlarge"
}

variable "endpoint_instance_count" {
  description = "Number of initial endpoint instances."
  type        = number
  default     = 1
}

variable "endpoint_instance_type" {
  description = "Instance type for inference endpoint."
  type        = string
  default     = "ml.m4.xlarge"
}

variable "max_number_training_jobs" {
  description = "Maximum number of total training jobs for hyperparameter tuning."
  type        = number
  default     = 3
}

variable "max_parallel_training_jobs" {
  description = "Maximimum number of training jobs running in parallel for hyperparameter tuning."
  type        = number
  default     = 1
}

variable "training_job_instance_count" {
  description = "Number of instances for training jobs."
  type        = number
  default     = 1
}

variable "training_job_instance_type" {
  description = "Instance type for training jobs."
  type        = string
  default     = "ml.m4.xlarge"
}

variable "training_job_storage_in_gb" {
  description = "Instance volume size in GB for training jobs."
  type        = number
  default     = 30
}

variable "static_hyperparameters" {
  description = <<EOF
Map of hyperparameter names to static values, which should not be altered during hyperparameter tuning.
E.g. `{ "kfold_splits" = "5" }`
EOF
  type        = map
  default = {
    kfold_splits = "5"
  }
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
  type = map(list(object({
    Name        = string
    MinValue    = string
    MaxValue    = string
    ScalingType = string
  })))
  default = {
    ContinuousParameterRanges = [
      {
        Name        = "gamma",
        MinValue    = "0",
        MaxValue    = "10",
        ScalingType = "Auto"
      },
      {
        Name        = "min_child_weight",
        MinValue    = "1",
        MaxValue    = "20",
        ScalingType = "Auto"
      },
      {
        Name        = "subsample",
        MinValue    = "0.1",
        MaxValue    = "0.5",
        ScalingType = "Auto"
      },
      {
        Name        = "max_delta_step",
        MinValue    = "0",
        MaxValue    = "1",
        ScalingType = "Auto"
      },
      {
        Name        = "scale_pos_weight",
        MinValue    = "1",
        MaxValue    = "10",
        ScalingType = "Auto"
      }
    ],
    IntegerParameterRanges = [
      {
        Name        = "max_depth",
        MinValue    = "1",
        MaxValue    = "10",
        ScalingType = "Auto"
      }
    ]
  }
}

variable "built_in_model_image" {
  description = <<EOF
Tuning ranges for hyperparameters.
Specifying this means that 'bring-your-own' model is not required and the ECR image not created.
EOF
  type        = string
  default     = null
}

# ECR input variables

variable "byo_model_image_name" {
  description = "Image and repo name for bring your own model."
  type        = string
  default     = "byo-xgboost"
}

variable "byo_model_image_source_path" {
  description = "Local source path for bring your own model docker image."
  type        = string
  default     = "source/containers/ml-ops-byo-xgboost"
}

variable "byo_model_image_tag" {
  description = "Tag for bring your own model image."
  type        = string
  default     = "latest"
}

# Glue variables

variable "glue_job_name" {
  description = "Name of the Glue data transformation job name."
  type        = string
  default     = "data-transformation"
}

variable "glue_job_type" {
  description = "Type of Glue job (Spark or Python Shell)."
  type        = string
  default     = "pythonshell"
}
