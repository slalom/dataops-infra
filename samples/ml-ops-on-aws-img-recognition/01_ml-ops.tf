module "ml-ops" {

  # BOILERPLATE HEADER (NO NEED TO CHANGE):
  source = "../../catalog/aws/ml-ops"
  #source        = "git::https://github.com/slalom-ggp/dataops-infra.git//catalog/aws/data-lake?ref=main"
  name_prefix          = local.name_prefix
  environment          = module.env.environment
  resource_tags        = local.resource_tags
  aws_credentials_file = local.aws_credentials_file

  # ADD OR MODIFY CONFIGURATION HERE:

  job_name = "breast-cancer-detection"

  tuning_objective              = "Maximize"
  tuning_metric                 = "accuracy"
  inference_comparison_operator = "NumericGreaterThan"
  inference_metric_threshold    = 0.7
  endpoint_or_batch_transform   = "Batch Transform" # "Batch Transform" or "Create Model Endpoint Config"

  max_number_training_jobs    = 3
  max_parallel_training_jobs  = 1
  training_job_instance_type  = "ml.m5.xlarge"
  training_job_instance_count = 4
  training_job_storage_in_gb  = 30

  distributions = {'mpi': {
                      'enabled': True,
                      'processes_per_host': hvd_processes_per_host,
                      'custom_mpi_options': '-verbose --NCCL_DEBUG=INFO -x OMPI_MCA_btl_vader_single_copy_mechanism=none'
                          }
                  }

  model_dir = "s3://${aws_s3_bucket.model_store.id}/"

  hyperparameters = {'epochs': 25, 'batch-size' : 24, 'model_name': 'ResNet18'}

  inputs = "s3://${aws_s3_bucket.extracts_store.id}/data"
  remote_inputs = {'train' : inputs+'/train', 'validation' : inputs+'/validate', 
  'eval' : inputs+'/test'}

  /* OPTIONAL - CHANGE PATHS BELOW:

  # set score_local_path to 'null' if running endpoint inference

  train_local_path  = "source/data/train.csv"
  score_local_path  = "source/score/score.csv"

  script_path = "source/scripts/transform.py"
  whl_path    = "source/scripts/python/pandasmodule-0.1-py3-none-any.whl" # to automate creation of wheel file


  /* OPTIONALLY, COPY-PASTE ADDITIONAL SETTINGS FROM BELOW:

  # specifying built_in_model_image means that 'bring-your-own' model is not required and the ECR image not created

  built_in_model_image        = "811284229777.dkr.ecr.us-east-1.amazonaws.com/xgboost:latest"
  byo_model_image_source_path = "source/containers/ml-ops-byo-xgboost"
  byo_model_image_name        = "byo-xgboost"
  byo_model_image_tag         = "latest"

  glue_job_name       = "data-transformation"
  glue_job_spark_flag = false


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
