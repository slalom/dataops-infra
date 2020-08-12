module "ml-ops-img" {

  # BOILERPLATE HEADER (NO NEED TO CHANGE):
  source = "../../catalog/aws/ml-ops-img"
  #source        = "git::https://github.com/slalom-ggp/dataops-infra.git//catalog/aws/data-lake?ref=main"
  name_prefix          = local.name_prefix
  environment          = module.env.environment
  resource_tags        = local.resource_tags
  aws_credentials_file = local.aws_credentials_file

  # ADD OR MODIFY CONFIGURATION HERE:

  job_name              = "breast-cancer-detection"
  problem_type          = "Image Recognition"
  content_type          = "application/x-recordio"

  repo_name             = "img-recog-sample-image"
  src_img_path          = "source/containers/ml-ops-byo-resnet18/DockerScripts"

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

  enable_pred_db = "True"

  parameter_ranges = {
    ContinuousParameterRanges = [
      {
        Name        = "learning_rate",
        MinValue    = 0.001,
        MaxValue    = 0.2,
        ScalingType = "Auto"
      },
      {
        Name        = "epochs",
        MinValue    = 5
        MaxValue    = 40
        ScalingType = "Auto"
      },
      {
        Name        = "batch-size",
        MinValue    = 5
        MaxValue    = 40
        ScalingType = "Auto"
      },

    ],
    CategoricalParameterRanges = [
      {
        Name   = "activation",
        Values = ["sigmoid", "softmax", "relu", "tanh"]
      },
      {
        Name   = "loss_fn",
        Values = ["categorical_crossentropy", "binary_crossentropy", "categorical_hinge", "hinge"]
      }
    ]
  }
}
output "summary" {
  value = module.ml-ops.summary
}


