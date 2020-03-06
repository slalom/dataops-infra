resource "aws_lambda_function" "QueryTrainingStatus" {
  function_name = "QueryTrainingStatus"
  description   = "Queries the SageMaker training job and return the results."
  role          = "arn:aws:iam:::role/StepFunctionsMLOpsRole"
  handler       = "query_training_status.lambda_handler"
  filename      = "${path.module}/source/code/query_training_status.zip"
  runtime       = "python3.8"

  tags = local.resource_tags
}

resource "aws_lambda_function" "ExtractModelPath" {
  function_name = "ExtractModelPath"
  description   = "Queries the SageMaker model to return the model path."
  role          = "arn:aws:iam:::role/StepFunctionsMLOpsRole"
  handler       = "extract_model_path.lambda_handler"
  filename      = "${path.module}/source/code/extract_model_path.zip"
  runtime       = "python3.8"

  tags = local.resource_tags
}

resource "aws_lambda_function" "ExtractModelName" {
  function_name = "ExtractModelName"
  description   = "Queries the SageMaker model to return the model name."
  role          = "arn:aws:iam:::role/StepFunctionsMLOpsRole"
  handler       = "extract_model_name.lambda_handler"
  filename      = "${path.module}/source/code/extract_model_name.zip"
  runtime       = "python3.8"

  tags = local.resource_tags
}

resource "aws_lambda_function" "CheckEndpointExists" {
  function_name = "CheckEndpointExists"
  description   = "Queries if endpoint exists to determine create or update job."
  role          = "arn:aws:iam:::role/StepFunctionsMLOpsRole"
  handler       = "check_endpoint_exists.lambda_handler"
  filename      = "${path.module}/source/code/check_endpoint_exists.zip"
  runtime       = "python3.8"

  tags = local.resource_tags
}

resource "aws_lambda_function" "UniqueJobName" {
  function_name = "UniqueJobName"
  description   = "Creates a unique identifier for the hyperparameter tuning job."
  role          = "arn:aws:iam:::role/StepFunctionsMLOpsRole"
  handler       = "unique_job_name.lambda_handler"
  filename      = "${path.module}/source/code/unique_job_name.zip"
  runtime       = "python3.8"

  tags = local.resource_tags
}
