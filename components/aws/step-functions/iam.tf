# NOTE: IAM role includes SageMaker actions

resource "aws_iam_role" "step_functions_workflow_execution_role" {
  name = "StepFunctionsWorkflowExecutionRole"

  tags = var.resource_tags

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "states.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
EOF

}

resource "aws_iam_policy" "step_functions_workflow_execution_policy" {
  name        = "StepFunctionsWorkflowExecutionPolicy"
  description = "Policy for Step Function workflow execution"
  path        = "/"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "sagemaker:*",
                "iam:PassRole"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Effect": "Allow",
            "Action": [
                "events:DescribeRule",
                "events:PutRule",
                "events:PutTargets"
            ],
            "Resource": [
                "arn:aws:events:*:*:rule/StepFunctionsGetEventsForSageMakerTrainingJobsRule",
                "arn:aws:events:*:*:rule/StepFunctionsGetEventsForSageMakerTransformJobsRule",
                "arn:aws:events:*:*:rule/StepFunctionsGetEventsForSageMakerTuningJobsRule"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "lambda:InvokeFunction"
            ],
            "Resource": [
                "arn:aws:lambda:*:*:*"
            ]
        }
    ]
}
EOF
}


resource "aws_iam_role_policy_attachment" "step_functions_full_access" {
  role       = aws_iam_role.step_functions_workflow_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSStepFunctionsFullAccess"
}

resource "aws_iam_role_policy_attachment" "step_functions_workflow_execution" {
  role       = aws_iam_role.step_functions_workflow_execution_role.name
  policy_arn = aws_iam_policy.step_functions_workflow_execution_policy.arn
}