module "lambda_functions" {
  source        = "../../../components/aws/lambda-python"
  name_prefix   = var.name_prefix
  resource_tags = var.resource_tags
  environment   = var.environment

  runtime              = "python3.8"
  lambda_source_folder = "${path.module}/lambda-python"
  upload_to_s3         = false
  upload_to_s3_path    = null

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
    RenameBatchOutput = {
      description = "Renames batch transform output to .csv extension for Athena connection."
      handler     = "rename_batch_output.lambda_handler"
      environment = {}
      secrets     = {}
    }
    RunGlueCrawler = {
      description = "Runs Glue Crawler to create table of batch transformation output for Athena."
      handler     = "run_glue_crawler.lambda_handler"
      environment = {}
      secrets     = {}
    }
  }
}

module "triggered_lambda" {
  source        = "../../../components/aws/lambda-python"
  name_prefix   = var.name_prefix
  resource_tags = var.resource_tags
  environment   = var.environment

  runtime              = "python3.8"
  lambda_source_folder = "${path.module}/lambda-python"
  upload_to_s3         = false
  upload_to_s3_path    = null

  functions = {
    ExecuteStateMachine = {
      description = "Executes model training state machine when new training data lands in S3."
      handler     = "execute_state_machine.lambda_handler"
      environment = { "state_machine_arn" = "${module.step-functions.state_machine_arn}" }
      secrets     = {}
    }
  }
  s3_triggers = [
    {
      function_name = "ExecuteStateMachine"
      s3_bucket     = var.feature_store_override != null ? data.aws_s3_bucket.feature_store_override[0].id : aws_s3_bucket.feature_store[0].id
      s3_path       = "${var.model_name}/data/train/*"
    }
  ]
}

resource "aws_iam_policy" "lambda_policy" {
  name        = "${var.name_prefix}lambda_policy"
  description = "Policy for Lambda functions"
  path        = "/"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "sagemaker:Describe*",
                "sagemaker:List*",
                "sagemaker:BatchGetMetrics",
                "sagemaker:GetSearchSuggestions",
                "sagemaker:Search",
                "s3:*",
                "glue:StartCrawler"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role       = module.lambda_functions.lambda_iam_role
  policy_arn = aws_iam_policy.lambda_policy.arn
}

resource "aws_iam_policy" "lambda_step_function_policy" {
  name        = "${var.name_prefix}lambda_step_function_access"
  description = "Policy for Lambda access to execute the Step Function"
  path        = "/"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "states:StartExecution",
            "Resource": "${module.step-functions.state_machine_arn}"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_step_functions_policy_attachment" {
  role       = module.triggered_lambda.lambda_iam_role
  policy_arn = aws_iam_policy.lambda_step_function_policy.arn
}