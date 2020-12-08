output "summary" {
  description = "Summary of resources created by this module."
  value       = <<EOF


Step Functions summary:

  Training Workflow:  ${module.training_workflow.state_machine_name}

S3 summary:

  Feature Store: ${length(aws_s3_bucket.ml_bucket[0]) > 0 ? aws_s3_bucket.ml_bucket[0].id : ""}
  Source Repository: ${aws_s3_bucket.source_repository.id}
  Data Store: ${aws_s3_bucket.ml_bucket[0].id}
  Model Store: ${aws_s3_bucket.ml_bucket[0].id}

Commands:

  Trigger Step Functions by dropping data into S3 ML Bucket Store:

    1) aws s3 cp ${var.score_local_path} s3://${length(aws_s3_bucket.ml_bucket[0]) > 0 ? aws_s3_bucket.ml_bucket[0].id : ""}/input_data/score
    2) aws s3 cp ${var.train_local_path} s3://${length(aws_s3_bucket.ml_bucket[0]) > 0 ? aws_s3_bucket.ml_bucket[0].id : ""}/input_data/train

  Or execute Step Functions directly:

    1) aws stepfunctions start-execution --state-machine-arn ${module.training_workflow.state_machine_arn} --region=${var.environment.aws_region}
EOF
}
