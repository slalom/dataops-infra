# NOTE: IAM role includes actions for SageMaker and Lambda for ML Ops use-case

resource "aws_iam_role" "step_functions_ml_ops_role" {
  name                  = "${var.name_prefix}StepFunctionsRole"
  tags                  = var.resource_tags
  force_detach_policies = true
  assume_role_policy    = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "states.amazonaws.com",
          "lambda.amazonaws.com",
          "sagemaker.amazonaws.com"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

}

data "aws_iam_policy_document" "step_functions_ml_ops_policy_doc" {
  statement {
    sid = "1"
    actions = [
      "cloudwatch:PutMetricData",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:GetAuthorizationToken",
      "ecr:BatchGetImage",
      "iam:PassRole",
      "glue:StartJobRun",
      "glue:GetJobRun",
      "glue:BatchStopJobRun",
      "glue:GetJobRuns",
      "logs:DescribeLogStreams",
      "logs:CreateLogGroup",
      "logs:PutLogEvents",
      "logs:CreateLogStream",
      "sagemaker:CreateModel",
      "sagemaker:ListTags",
      "sagemaker:DescribeTrainingJob",
      "sagemaker:CreateEndpoint",
      "sagemaker:CreateTransformJob",
      "sagemaker:UpdateEndpoint",
      "sagemaker:CreateEndpointConfig",
      "sagemaker:CreateHyperParameterTuningJob",
      "sagemaker:ListEndpoints",
      "sagemaker:DescribeHyperParameterTuningJob",
      "sagemaker:StopHyperParameterTuningJob",
      "states:DescribeStateMachine",
      "states:UpdateStateMachine",
      "states:ListStateMachines",
      "states:DeleteStateMachine",
      "states:CreateStateMachine",
      "states:DescribeStateMachine"
    ]
    resources = ["*"]
  }
  statement {
    sid     = "2"
    actions = ["s3:ListBucket"]
    resources = [
      for b in var.writeable_buckets :
      "arn:aws:s3:::${b}/*"
    ]
  }
  statement {
    sid = "3"
    actions = [
      "s3:PutObject",
      "s3:GetObject",
    ]
    resources = [
      for b in var.writeable_buckets :
      "arn:aws:s3:::${b}"
    ]
  }
  statement {
    sid = "2"
    actions = [
      "events:PutTargets",
      "events:DescribeRule",
      "events:PutRule",
      "lambda:InvokeFunction",
    ]
    resources = flatten([
      [
        "arn:aws:events:*:*:rule/StepFunctionsGetEventsForSageMakerTrainingJobsRule",
        "arn:aws:events:*:*:rule/StepFunctionsGetEventsForSageMakerTransformJobsRule",
        "arn:aws:events:*:*:rule/StepFunctionsGetEventsForSageMakerTuningJobsRule",
      ],
      [
        for l in values(var.lambda_functions) : l
      ]
    ])
  }
}

resource "aws_iam_policy" "step_functions_ml_ops_policy" {
  name        = "${var.name_prefix}StepFunctionsPolicy"
  description = "Policy for Step Function MLOps Workflow"
  path        = "/"

  policy = data.aws_iam_policy_document.step_functions_ml_ops_policy_doc.json
}

resource "aws_iam_role_policy_attachment" "step_functions_ml_ops_policy_attachment" {
  role       = aws_iam_role.step_functions_ml_ops_role.name
  policy_arn = aws_iam_policy.step_functions_ml_ops_policy.arn
}
