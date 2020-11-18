# NOTE: IAM role includes actions for SageMaker and Lambda for ML Ops use-case

resource "random_id" "suffix" {
  byte_length = 2
}

resource "aws_iam_role" "step_functions_role" {
  name                  = "${var.name_prefix}StepFunctionsRole-${random_id.suffix.dec}"
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

data "aws_iam_policy_document" "step_functions_policy_doc" {
  statement {
    sid = "1"
    actions = [
      "cloudwatch:PutMetricData",
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:GetAuthorizationToken",
      "ecr:GetDownloadUrlForLayer",
      "ecs:RunTask",
      "ecs:StopTask",
      "ecs:DescribeTasks",
      "iam:PassRole",
      "glue:BatchStopJobRun",
      "glue:GetJobRun",
      "glue:GetJobRuns",
      "glue:StartJobRun",
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:DescribeLogStreams",
      "logs:PutLogEvents",
      "sagemaker:CreateEndpoint",
      "sagemaker:CreateEndpointConfig",
      "sagemaker:CreateHyperParameterTuningJob",
      "sagemaker:CreateModel",
      "sagemaker:CreateTransformJob",
      "sagemaker:DescribeHyperParameterTuningJob",
      "sagemaker:DescribeTrainingJob",
      "sagemaker:ListEndpoints",
      "sagemaker:ListTags",
      "sagemaker:StopHyperParameterTuningJob",
      "sagemaker:UpdateEndpoint",
      "states:CreateStateMachine",
      "states:DeleteStateMachine",
      "states:DescribeStateMachine",
      "states:ListStateMachines",
      "states:UpdateStateMachine",
    ]
    resources = ["*"]
  }
  dynamic "statement" {
    # Must be dynamic, to prevent failure when case number of grants is zero.
    for_each = length(var.writeable_buckets) > 0 ? ["1"] : []
    content {
      sid     = "2"
      actions = ["s3:ListBucket"]
      resources = [
        for b in var.writeable_buckets :
        "arn:aws:s3:::${b}/*"
      ]
    }
  }
  dynamic "statement" {
    # Must be dynamic, to prevent failure when case number of grants is zero.
    for_each = length(var.writeable_buckets) > 0 ? ["1"] : []
    content {
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
  }
  statement {
    sid = "4"
    actions = [
      "events:DescribeRule",
      "events:PutRule",
      "events:PutTargets",
    ]
    resources = [
      "arn:aws:events:*:*:rule/StepFunctionsGetEventsForECSTaskRule",
      "arn:aws:events:*:*:rule/StepFunctionsGetEventsForSageMakerTrainingJobsRule",
      "arn:aws:events:*:*:rule/StepFunctionsGetEventsForSageMakerTransformJobsRule",
      "arn:aws:events:*:*:rule/StepFunctionsGetEventsForSageMakerTuningJobsRule",
    ]
  }
  dynamic "statement" {
    # Must be dynamic, to prevent failure when case number of grants is zero.
    for_each = length(values(var.lambda_functions)) > 0 ? ["1"] : []
    content {
      sid = "5"
      actions = [
        "lambda:InvokeFunction",
      ]
      resources = [
        for l in values(var.lambda_functions) : l
      ]
    }
  }
}

resource "aws_iam_policy" "step_functions_policy" {
  name        = "${var.name_prefix}StepFunctionsPolicy"
  description = "Policy for Step Function Workflow"
  path        = "/"
  policy      = data.aws_iam_policy_document.step_functions_policy_doc.json
}

resource "aws_iam_role_policy_attachment" "step_functions_policy_attachment" {
  role       = aws_iam_role.step_functions_role.name
  policy_arn = aws_iam_policy.step_functions_policy.arn
}

# Access for Cloudwatch schedulers to invoke the step function:

resource "aws_iam_role" "cloudwatch_invoke_role" {
  name                  = "${var.name_prefix}StepFunction_InvokeRole-${random_id.suffix.dec}"
  tags                  = var.resource_tags
  force_detach_policies = true
  assume_role_policy    = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "events.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "cloudwatch_invoke_policy" {
  name        = "${var.name_prefix}CW_StepFunction_InvokePolicy"
  description = "Policy for Cloudwatch to Invoke the Step Function Workflow"
  path        = "/"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "states:StartExecution"
      ],
      "Resource": [
        "${aws_sfn_state_machine.state_machine.id}"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "cloudwatch_invoke_policy_attachment" {
  role       = aws_iam_role.cloudwatch_invoke_role.name
  policy_arn = aws_iam_policy.cloudwatch_invoke_policy.arn
}
