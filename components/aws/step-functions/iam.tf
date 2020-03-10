# NOTE: IAM role includes actions for SageMaker and Lambda for ML Ops use-case

resource "aws_iam_role" "step_functions_ml_ops_role" {
  name = "${var.name_prefix}StepFunctionsRole"

  tags = var.resource_tags

  assume_role_policy = <<EOF
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

resource "aws_iam_policy" "step_functions_ml_ops_policy" {
  name        = "${var.name_prefix}StepFunctionsPolicy"
  description = "Policy for Step Function MLOps Workflow"
  path        = "/"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "states:DescribeStateMachine",
                "states:UpdateStateMachine",
                "states:ListStateMachines",
                "states:DeleteStateMachine",
                "states:CreateStateMachine",
                "states:DescribeStateMachine",
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
                "ecr:BatchCheckLayerAvailability",
                "ecr:GetDownloadUrlForLayer",
                "ecr:GetAuthorizationToken",
                "ecr:BatchGetImage",
                "cloudwatch:PutMetricData",
                "logs:DescribeLogStreams",
                "logs:CreateLogGroup",
                "logs:PutLogEvents",
                "logs:CreateLogStream",
                "iam:PassRole"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:PutObject",
                "s3:GetObject",
                "events:PutTargets",
                "events:DescribeRule",
                "lambda:InvokeFunction",
                "events:PutRule"
            ],
            "Resource": [
                "arn:aws:s3:::${var.s3_bucket_name}/*",
                "arn:aws:events:*:*:rule/StepFunctionsGetEventsForSageMakerTrainingJobsRule",
                "arn:aws:events:*:*:rule/StepFunctionsGetEventsForSageMakerTransformJobsRule",
                "arn:aws:events:*:*:rule/StepFunctionsGetEventsForSageMakerTuningJobsRule",
                "${
  join(
    "\",\n                \"",
    values(module.lambda_functions.function_ids)
  )
}"
            ]
        },
        {
            "Effect": "Allow",
            "Action": "s3:ListBucket",
            "Resource": "arn:aws:s3:::${var.s3_bucket_name}"
        }
    ]
}
EOF
}


resource "aws_iam_role_policy_attachment" "step_functions_ml_ops_policy_attachment" {
  role       = aws_iam_role.step_functions_ml_ops_role.name
  policy_arn = aws_iam_policy.step_functions_ml_ops_policy.arn
}
