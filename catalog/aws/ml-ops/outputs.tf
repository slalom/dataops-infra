data "null_data_source" "endpoint_or_batch_output" {
  inputs = {
    # State machine input for creating or updating an inference endpoint
    endpoint = <<EOF
1) aws s3 cp ${var.train_local_path} s3://${length(aws_s3_bucket.feature_store) > 0 ? aws_s3_bucket.feature_store[0].id : ""}/data/train/train.csv
EOF
    # State machine input for batch transformation
    batch_transform = <<EOF
1) aws s3 cp ${var.score_local_path} s3://${length(aws_s3_bucket.feature_store) > 0 ? aws_s3_bucket.feature_store[0].id : ""}/data/score/score.csv
    2) aws s3 cp ${var.train_local_path} s3://${length(aws_s3_bucket.feature_store) > 0 ? aws_s3_bucket.feature_store[0].id : ""}/data/train/train.csv
EOF
  }
}

output "summary" {
  description = "Summary of resources created by this module."
  value       = <<EOF


Step Functions summary:

  State Machine Name: ${module.step-functions.state_machine_name}

S3 summary:

  Feature Store: ${length(aws_s3_bucket.feature_store) > 0 ? aws_s3_bucket.feature_store[0].id : ""}
  Source Repository: ${aws_s3_bucket.source_repository.id}
  Extracts Store: ${aws_s3_bucket.extracts_store.id}
  Model Store: ${aws_s3_bucket.model_store.id}
  Metadata Store: ${aws_s3_bucket.metadata_store.id}
  Output Store: ${aws_s3_bucket.output_store.id}
  Monitor Output Store: ${aws_s3_bucket.monitor_output_store.id}

Commands:

  Trigger Step Functions by dropping data into S3 Feature Store:

    ${var.endpoint_or_batch_transform == "Create Model Endpoint Config" ? data.null_data_source.endpoint_or_batch_output.outputs["endpoint"] : data.null_data_source.endpoint_or_batch_output.outputs["batch_transform"]}

  Or execute Step Functions directly:

    1) aws stepfunctions start-execution --state-machine-arn ${module.step-functions.state_machine_arn}
EOF
}
