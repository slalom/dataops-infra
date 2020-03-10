module "lambda_functions" {
  source        = "../../components/aws/lambda-python"
  name_prefix   = var.name_prefix
  resource_tags = var.resource_tags
  environment   = var.environment

  lambda_source_folder = "${path.module}/lambda-python"
  runtime              = "python3.8"

  functions = {
    QueryTrainingStatus = {
      description = "Queries the SageMaker training job and return the results."
      handler     = "query_training_status.lambda_handler"
      environment = {}
      secrets     = {}
    }
    ExtractModelPath = {
      description = "Queries the SageMaker model to return the model path."
      handler     = "extract_model_path.lambda_handler"
      environment = {}
      secrets     = {}
    }
    ExtractModelName = {
      description = "Queries the SageMaker model to return the model name."
      handler     = "extract_model_name.lambda_handler"
      environment = {}
      secrets     = {}
    }
    CheckEndpointExists = {
      description = "Queries if endpoint exists to determine create or update job."
      handler     = "check_endpoint_exists.lambda_handler"
      environment = {}
      secrets     = {}
    }
    UniqueJobName = {
      description = "Creates a unique identifier for the hyperparameter tuning job."
      handler     = "unique_job_name.lambda_handler"
      environment = {}
      secrets     = {}
    }
  }
}
