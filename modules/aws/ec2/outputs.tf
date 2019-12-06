output "ssh_key_name" { value = length(aws_instance.linux_tableau_server) == 0 ? "n/a" : aws_instance.linux_tableau_server[0].key_name }
output "ssh_public_key_path" { value = local.ssh_public_key_filepath }
output "ssh_private_key_path" { value = local.ssh_private_key_filepath }

output "ec2_linux_instance_id" { value = length(aws_instance.linux_tableau_server) == 0 ? "n/a" : aws_instance.linux_tableau_server[0].id }
output "ec2_linux_public_ip" { value = length(aws_instance.linux_tableau_server) == 0 ? "n/a" : aws_instance.linux_tableau_server[0].public_ip }
output "ec2_linux_private_ip" { value = length(aws_instance.linux_tableau_server) == 0 ? "n/a" : aws_instance.linux_tableau_server[0].private_ip }
output "ec2_linux_instance_state" { value = length(aws_instance.linux_tableau_server) == 0 ? "n/a" : aws_instance.linux_tableau_server[0].instance_state }
output "ec2_windows_public_ip" { value = length(aws_instance.windows_tableau_server) == 0 ? "n/a" : aws_instance.windows_tableau_server[0].public_ip }
output "ec2_windows_instance_password" {
  value = (
    length(aws_instance.windows_tableau_server) == 0 ? "n/a" :
    length(aws_instance.windows_tableau_server[0].password_data) == 0 ? "n/a" :
    fileexists(local.ssh_private_key_filepath) == false ? "n/a" :
    rsadecrypt(aws_instance.windows_tableau_server[0].password_data, file(local.ssh_private_key_filepath))
  )
}
