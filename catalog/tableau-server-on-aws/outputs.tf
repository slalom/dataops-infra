output "ssh_public_key_path" { value = local.ssh_public_key_filepath }
output "ssh_private_key_path" { value = local.ssh_private_key_filepath }
output "ec2_linux_instance_id" { value = var.num_linux_instances == 0 ? "n/a" : module.linux_tableau_server.instance_id }
output "ec2_linux_public_ip" { value = var.num_linux_instances == 0 ? "n/a" : module.linux_tableau_server.public_ip }
output "ec2_linux_private_ip" { value = var.num_linux_instances == 0 ? "n/a" : module.linux_tableau_server.private_ip }
output "ec2_linux_instance_state" { value = var.num_linux_instances == 0 ? "n/a" : module.linux_tableau_server.instance_state }
output "ec2_windows_public_ip" { value = var.num_windows_instances == 0 ? "n/a" : module.windows_tableau_server.public_ip }
output "ec2_windows_instance_password" { value = var.num_windows_instances == 0 ? "n/a" : module.windows_tableau_server.windows_instance_password }
# output "ssh_key_name" { value = var.num_linux_instances == 0 ? "n/a" : module.linux_tableau_server[0].key_name }
