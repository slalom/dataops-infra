output "glue_crawler_name" {
  description = "The name of the Glue crawler."
  value       = "${aws_glue_crawler.glue_crawler.id}"
}
