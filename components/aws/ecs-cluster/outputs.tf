output "ecs_cluster_name" {
  value = (
    length(aws_ecs_cluster.ecs_cluster.arn) > 0 ?
    aws_ecs_cluster.ecs_cluster.name : "null"
  )
}
output "ecs_cluster_arn" { value = aws_ecs_cluster.ecs_cluster.arn }
output "ecs_instance_role" { value = aws_iam_role.ecs_instance_role.name }
