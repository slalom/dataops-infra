output "ssh_key_name" { value = length(aws_instance.ec2_instance) == 0 ? "n/a" : aws_instance.ec2_instance[0].key_name }
output "ssh_public_key_path" { value = local.ssh_public_key_filepath }
output "ssh_private_key_path" { value = local.ssh_private_key_filepath }
output "instance_id" { value = length(aws_instance.ec2_instance) == 0 ? "n/a" : aws_instance.ec2_instance[0].id }
output "public_ip" { value = length(aws_instance.ec2_instance) == 0 ? "n/a" : aws_instance.ec2_instance[0].public_ip }
output "private_ip" { value = length(aws_instance.ec2_instance) == 0 ? "n/a" : aws_instance.ec2_instance[0].private_ip }
output "instance_state" { value = length(aws_instance.ec2_instance) == 0 ? "n/a" : aws_instance.ec2_instance[0].instance_state }
output "windows_instance_password" {
  value = (
    length(aws_instance.ec2_instance) == 0 ? "n/a" :
    length(aws_instance.ec2_instance[0].password_data) == 0 ? "n/a" :
    fileexists(var.ssh_private_key_filepath) == false ? "n/a" :
    rsadecrypt(aws_instance.ec2_instance[0].password_data, file(var.ssh_private_key_filepath))
  )
}
