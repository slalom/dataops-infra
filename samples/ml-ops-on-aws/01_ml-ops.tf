module "ml-ops" {

  # BOILERPLATE HEADER (NO NEED TO CHANGE):
  source = "../../catalog/aws/ml-ops"
  #source        = "git::https://github.com/slalom-ggp/dataops-infra.git//catalog/aws/data-lake?ref=master"
  name_prefix   = local.name_prefix
  environment   = module.env.environment
  resource_tags = local.resource_tags

  # ADD OR MODIFY CONFIGURATION HERE:

  job_name = "employee-attrition"

  /* OPTIONAL - CHANGE PATHS BELOW:

  train_local_path  = "source/data/train.csv"
  score_local_path  = "source/score/score.csv"

  script_path = "source/scripts/transform.py"
  whl_path    = "source/scripts/python/pandasmodule-0.1-py3-none-any.whl" # to automate creation of wheel file

  byo_model_source_image_path = "source/containers/ml-ops-byo-xgboost"
  

  /* OPTIONALLY, COPY-PASTE ADDITIONAL SETTINGS FROM BELOW:

  byo_model_repo_name = "byo-xgboost"
  byo_model_tag       = "latest"

  glue_job_name       = "data-transformation"
  glue_job_type       = "pythonshell"

  tuning_objective              = "Maximize"
  tuning_metric                 = "accuracy"
  inference_comparison_operator = "NumericGreaterThan"
  inference_metric_threshold    = 0.7
  endpoint_or_batch_transform   = "Batch Transform" # "Batch Transform" or "Create Model Endpoint Config"

  max_number_training_jobs    = 3
  max_parallel_training_jobs  = 1
  training_job_instance_type  = "ml.m4.xlarge"
  training_job_instance_count = 1
  training_job_volume_size_gb = 30

  static_hyperparameters = {
    kfold_splits = "5"
  }

  parameter_ranges = {
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


  OPTIONAL - USE INSTEAD TO SET TRAINING_IMAGE TO AWS BUILT-IN ALGORITHM:

  training_image_override = "811284229777.dkr.ecr.us-east-1.amazonaws.com/xgboost:latest"


  OPTIONAL - IF USING BATCH TRANSFORMATION INFERENCE:
  
  batch_transform_instance_type  = "ml.m4.xlarge"
  batch_transform_instance_count = 1

  
  OPTIONAL - IF USING ENDPOINT INFERENCE:

  endpoint_instance_Type  = "ml.m4.xlarge"
  endpoint_instance_count = 1
  endpoint_name           = "attrition-endpoint"

  */
}

output "summary" {
  value = module.ml-ops.summary
}
