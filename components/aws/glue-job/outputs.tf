output "glue_job_name" {
  description = "The name of the Glue job."
  value       = "${aws_glue_job.glue_job.id}"
}
