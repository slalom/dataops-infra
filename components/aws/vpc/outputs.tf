output "vpc_id" {
  description = "The unique ID of the VPC."
  value       = var.disabled ? null : aws_vpc.my_vpc[0].id
}
output "private_subnets" {
  description = "The list of private subnets."
  value       = var.disabled || length(aws_subnet.private_subnets) == 0 ? null : toset(aws_subnet.private_subnets.*.id)
}
output "public_subnets" {
  description = "The list of public subnets."
  value       = var.disabled || length(aws_subnet.public_subnets) == 0 ? null : toset(aws_subnet.public_subnets.*.id)
}
