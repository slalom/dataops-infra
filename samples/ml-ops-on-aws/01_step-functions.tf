data "aws_caller_identity" "current" {} # To delete when ECR module created

module "ml-ops-on-aws" {
  #source        = "git::https://github.com/slalom-ggp/dataops-infra.git//catalog/aws/data-lake?ref=master"
  source        = "../../catalog/aws/ml-ops-on-aws"
  name_prefix   = local.name_prefix
  environment   = module.env.environment
  resource_tags = local.resource_tags

  # Training data source and upload
  s3_bucket_name = module.s3_store_and_lambdas.s3_data_bucket

  /* OPTIONAL - CHANGE PATHS BELOW:

  # data_s3_path = "data"
  # data_folder  = "source/data" 

  */

  # ECR input
  byo_model_repo_name         = "byo-xgboost"
  byo_model_source_image_path = "${path.module}/source/containers/ml-ops-byo-xgboost"
  #data_transform_repo_name         = "data-transform"
  #data_transform_source_image_path = "${path.module}/source/containers/ml-ops-data-transform"

  # State Machine input
  job_name       = "attrition"
  endpoint_name  = "attrition-endpoint"
  training_image = "${module.ml-ops-on-aws.byo_model_image_url}"
  # Use instead to set training_image to AWS built-in algorithm
  #training_image                  = "811284229777.dkr.ecr.us-east-1.amazonaws.com/xgboost:latest"
  tuning_objective              = "Maximize"
  tuning_metric                 = "accuracy"
  inference_comparison_operator = "NumericGreaterThan"
  inference_metric_threshold    = 0.7
  endpoint_or_batch_transform   = "Batch Transform" # Batch Transform or Create Model Endpoint Config
  max_number_training_jobs      = 3
  max_parallel_training_jobs    = 3

  static_hyperparameters = {
    "kfold_splits" = "5"
  }

  parameter_ranges = {
    "ContinuousParameterRanges" = [
      {
        "Name"        = "gamma",
        "MinValue"    = "0",
        "MaxValue"    = "10",
        "ScalingType" = "Auto"
      },
      {
        "Name"        = "min_child_weight",
        "MinValue"    = "1",
        "MaxValue"    = "20",
        "ScalingType" = "Auto"
      },
      {
        "Name"        = "subsample",
        "MinValue"    = "0.1",
        "MaxValue"    = "0.5",
        "ScalingType" = "Auto"
      },
      {
        "Name"        = "max_delta_step",
        "MinValue"    = "0",
        "MaxValue"    = "1",
        "ScalingType" = "Auto"
      },
      {
        "Name"        = "scale_pos_weight",
        "MinValue"    = "1",
        "MaxValue"    = "10",
        "ScalingType" = "Auto"
      }
    ],
    "IntegerParameterRanges" = [
      {
        "Name"        = "max_depth",
        "MinValue"    = "1",
        "MaxValue"    = "10",
        "ScalingType" = "Auto"
      }
    ]
  }
}

output "summary" {
  value = <<EOF


Step Functions summary:
 ${module.ml-ops-on-aws.summary}

S3 summary:

 S3 Bucket Name: ${module.s3_store_and_lambdas.s3_data_bucket}
EOF
}