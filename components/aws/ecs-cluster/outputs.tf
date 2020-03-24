output "ecs_cluster_name" {
  description = "The name of the ECS cluster."
  value = (
    length(aws_ecs_cluster.ecs_cluster.arn) > 0 ?
    aws_ecs_cluster.ecs_cluster.name : "null"
  )
}
output "ecs_cluster_arn" {
  description = "The unique ID (ARN) of the ECS cluster."
  value       = aws_ecs_cluster.ecs_cluster.arn
}
output "ecs_instance_role" {
  description = "The name of the IAM instance role used by the ECS cluster. (Can be used to grant additional permissions.)"
  value       = aws_iam_role.ecs_instance_role.name
}
