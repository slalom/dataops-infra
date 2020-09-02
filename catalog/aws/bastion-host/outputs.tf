output "summary" {
  description = "Summary of resources created by this module."
  value       = <<EOF


Bastion Host Summary:

 - ECS Tasks URL:  https://console.aws.amazon.com/ecs/home?region=${var.environment.aws_region}#/clusters/${module.ecs_bastion_cluster.ecs_cluster_name}/tasks
 - Logging URL:    ${module.ecs_bastion_task.ecs_logging_url}
 - Uploaded image: ${var.custom_base_image != null ? module.ecr_image[0].ecr_image_url_and_tag : "n/a"}
 - Connect to remote Bastion Host using SSH:
     ssh -o StrictHostKeyChecking=no -i "${coalesce(var.ssh_private_key_filepath, "n\\a")}" root@<public-ip>
 - Command to test docker image locally:
     docker run --rm -it --entrypoint bash ${var.custom_base_image != null ? module.ecr_image[0].ecr_image_url_and_tag : "n/a"}
 - Command to host the SSH server locally:
     docker run --rm -it -e SSH_PUBLIC_KEY_BASE64=${local.ssh_public_key_base64} ${var.custom_base_image != null ? module.ecr_image[0].ecr_image_url_and_tag : "n/a"}

EOF
}
