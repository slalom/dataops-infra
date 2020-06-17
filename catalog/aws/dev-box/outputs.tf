output "summary" {
  description = "Summary of resources created by this module."
  value       = <<EOF


Dev Box Summary:

 - ECS Tasks URL:  https://console.aws.amazon.com/ecs/home?region=${var.environment.aws_region}#/clusters/${module.ecs_dev_box_cluster.ecs_cluster_name}/tasks
 - Logging URL:    ${module.ecs_dev_box_task.ecs_logging_url}
 - Uploaded image: ${module.ecr_image.ecr_image_url_and_tag}
 - Connect to remote Dev Box using SSH:
     ssh -o StrictHostKeyChecking=no -i "${coalesce(var.ssh_private_key_filepath, "n\\a")}" root@<public-ip>
 - Command to test docker image locally:
     docker run --rm -it --entrypoint bash ${module.ecr_image.ecr_image_url_and_tag}
 - Command to host the SSH server locally:
     docker run --rm -it -e SSH_PUBLIC_KEY_BASE64=${local.ssh_public_key_base64} ${module.ecr_image.ecr_image_url_and_tag}

EOF
}
