variable "name_prefix" {
  type = string
}

variable "s3_bucket_name" {
  type = string
}

variable "data_folder" {
  type    = string
  default = "source/data"
}

variable "data_s3_path" {
  type    = string
  default = "data"
}

variable "environment" {
  type = object({
    vpc_id          = string
    aws_region      = string
    public_subnets  = list(string)
    private_subnets = list(string)
  })
}

variable "resource_tags" {
  type    = map
  default = {}
}

# State Machine input variables

variable "job_name" {
  type    = string
  default = "xgboost-job"
}

variable "endpoint_name" {
  type    = string
  default = "xgboost-endpoint"
}

variable "training_image" {
  type    = string
  default = "811284229777.dkr.ecr.us-east-1.amazonaws.com/xgboost:1"
}

variable "tuning_objective" {
  type    = string
  default = "Minimize"
}

variable "tuning_metric" {
  type    = string
  default = "validation:error"
}

variable "create_endpoint_error_threshold" {
  type    = number
  default = 0.2
}

variable "max_number_training_jobs" {
  type    = number
  default = 2
}

variable "max_parallel_training_jobs" {
  type    = number
  default = 2
}

variable "parameter_ranges" {
  type    = string
  default = <<EOF
   {
      "ContinuousParameterRanges": [
        {
          "Name": "eta",
          "MinValue": "0.1",
          "MaxValue": "0.5",
          "ScalingType": "Auto"
        },
        {
          "Name": "min_child_weight",
          "MinValue": "5",
          "MaxValue": "100",
          "ScalingType": "Auto"
        },
        {
          "Name": "subsample",
          "MinValue": "0.1",
          "MaxValue": "0.5",
          "ScalingType": "Auto"
        },
        {
          "Name": "gamma",
          "MinValue": "0",
          "MaxValue": "5",
          "ScalingType": "Auto"
        }
      ],
      "IntegerParameterRanges": [
        {
          "Name": "max_depth",
          "MinValue": "0",
          "MaxValue": "10",
          "ScalingType": "Auto"
        }
      ]
    }
EOF
}