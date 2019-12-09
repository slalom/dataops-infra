output "ssh_public_key_path" { value = local.ssh_public_key_filepath }
output "ssh_private_key_path" { value = local.ssh_private_key_filepath }
output "ec2_instance_ids" { value = flatten([module.linux_tableau_servers.instance_ids, module.windows_tableau_servers.instance_ids]) }
output "ec2_instance_public_ips" { value = merge(module.linux_tableau_servers.public_ips, module.windows_tableau_servers.public_ips) }
output "ec2_instance_private_ips" { value = merge(module.linux_tableau_servers.private_ips, module.windows_tableau_servers.private_ips) }
output "ec2_instance_states" { value = merge(module.linux_tableau_servers.instance_states, module.windows_tableau_servers.instance_states) }
output "ec2_remote_admin_commands" { value = merge(module.linux_tableau_servers.remote_admin_commands, module.windows_tableau_servers.remote_admin_commands) }
output "ec2_windows_instance_passwords" { value = module.windows_tableau_servers.windows_instance_passwords }
# output "ssh_key_name" { value = var.num_linux_instances == 0 ? "n/a" : module.linux_tableau_servers[0].key_name }
# TODO: Detect EC2 Pricing
# output "ec2_instance_hr_base_price" {
#   # estimated base price of the (linux) instance type, excluding upcharge for Windows instance and excluding any special pricing or reservation discounts.
#   value = module.linux_tableau_servers.instance_hr_list_price
# }
output "summary" {
  value = chomp(<<EOF
${var.num_linux_instances == 0 ? "" : join("\n", values(module.linux_tableau_servers.remote_admin_commands))}
${var.num_windows_instances == 0 ? "" : join("\n", values(module.windows_tableau_servers.remote_admin_commands))}
EOF
)
}

# HOW TO CONNECT:
# ---------------
# ${var.is_windows == true ? "Windows" : "Linux"}:
#   TSM Admin:    https://${module.linux_tableau_servers[0].public_ip}:8850
#   Tableau:      https://${module.linux_tableau_servers[0].public_ip}"
#   Remote Admin: ${local.instance_connect_cmd}
#   Creds:        Administrator:${aws_instance.ec2_instance.windows_instance_password}
# ---------------
