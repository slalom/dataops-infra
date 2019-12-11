output "vpc_id" { value = "${aws_vpc.myVPC.id}" }
output "private_subnet_ids" { value = "${aws_subnet.private_subnets.*.id}" }
output "public_subnet_ids" { value = "${aws_subnet.public_subnets.*.id}" }
output "ecs_security_group" { value = "${aws_security_group.ecs_tasks_sg.id}" }
