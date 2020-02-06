output "vpc_id" { value = var.disabled ? null : aws_vpc.my_vpc[0].id }
output "private_subnets" {
    value = var.disabled || length(aws_subnet.private_subnets) == 0 ? null : aws_subnet.private_subnets[0].*.id
}
output "public_subnets" { 
    value = var.disabled || length(aws_subnet.public_subnets) == 0 ? null : aws_subnet.public_subnets[0].*.id
}
