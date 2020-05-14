output "glue_job_name" {
  description = "The name of the Glue job."
  value       = aws_glue_job.glue_job.id
}
output "summary" {
  description = "Summary of Glue resources created."
  value       = <<EOF


Glue ETL Job Summary:

  Job Name:    ${aws_glue_job.glue_job.id}
  Run Command: aws glue start-job-run --job-name ${aws_glue_job.glue_job.id}

EOF
}
