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

  # State Machine input
  job_name = "customerchurn"
  endpoint_name = "customerchurn-endpoint"
  training_image = "811284229777.dkr.ecr.us-east-1.amazonaws.com/xgboost:1"
  tuning_objective = "Minimize"
  tuning_metric = "validation:error"
  create_endpoint_error_threshold = 0.2
  max_number_training_jobs = 2
  max_parallel_training_jobs = 2

  parameter_ranges = <<EOF
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

output "summary" {
  value = <<EOF


Step Functions summary:
 ${module.ml-ops-on-aws.summary}

S3 summary:

 S3 Bucket Name: ${module.s3_store_and_lambdas.s3_data_bucket}
EOF
}