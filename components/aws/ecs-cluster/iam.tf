# module "aws_iam" {
#   source      = "../iam"
#   name_prefix = "${var.name_prefix}ECSClusterIAM-"
# }

resource "aws_iam_role" "ecs_instance_role" {
  name               = "${var.name_prefix}ECSInstanceRole-${random_id.suffix.dec}"
  tags               = var.resource_tags
  assume_role_policy = <<EOF
{
"Version": "2012-10-17",
"Statement": [
  {
    "Effect": "Allow",
    "Principal": {
      "Service": "ec2.amazonaws.com"
    },
    "Action": "sts:AssumeRole"
  }
]
}
EOF
}

resource "aws_iam_role_policy" "ecs_instance_role_policy" {
  name   = "ecs_instance_role_policy-${random_id.suffix.dec}"
  role   = aws_iam_role.ecs_instance_role.id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecs:CreateCluster",
        "ecs:DeregisterContainerInstance",
        "ecs:DiscoverPollEndpoint",
        "ecs:Poll",
        "ecs:RegisterContainerInstance",
        "ecs:StartTelemetrySession",
        "ecs:Submit*",
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "ecs:StartTask"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}
