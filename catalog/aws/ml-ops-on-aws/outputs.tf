output "summary" {
  description = "Summary of resources created by this module."
  value       = <<EOF


Step Functions summary:

  State Machine Name: ${module.step-functions.state_machine_name}

S3 summary:

  Feature Store: ${aws_s3_bucket.feature_store[0].id}
  Source Repository: ${aws_s3_bucket.source_repository.id}
  Extracts Store: ${aws_s3_bucket.extracts_store.id}
  Model Store: ${aws_s3_bucket.model_store.id}
  Output Store: ${aws_s3_bucket.output_store.id}

Commands:

  Trigger Step Functions by dropping data into S3 Feature Store:

    1) aws s3 cp ${var.score_local_path} s3://${aws_s3_bucket.feature_store[0].id}/${var.job_name}/data/score/score.csv
    2) aws s3 cp ${var.train_local_path} s3://${aws_s3_bucket.feature_store[0].id}/${var.job_name}/data/train/train.csv

  Or execute Step Functions directly:

    1) aws stepfunctions start-execution --state-machine-arn ${module.step-functions.state_machine_arn}
EOF
}