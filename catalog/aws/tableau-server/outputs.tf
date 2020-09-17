locals {
  ec2_instance_ids          = flatten([module.linux_tableau_servers.instance_ids, module.windows_tableau_servers.instance_ids])
  ec2_instance_public_ips   = merge(module.linux_tableau_servers.public_ips, module.windows_tableau_servers.public_ips)
  ec2_instance_private_ips  = merge(module.linux_tableau_servers.private_ips, module.windows_tableau_servers.private_ips)
  ec2_instance_states       = merge(module.linux_tableau_servers.instance_states, module.windows_tableau_servers.instance_states)
  ec2_remote_admin_commands = merge(module.linux_tableau_servers.remote_admin_commands, module.windows_tableau_servers.remote_admin_commands)
}
output "ec2_instance_ids" {
  description = "The EC2 intance ID(s) created by the module."
  value       = local.ec2_instance_ids
}
output "ec2_instance_private_ips" {
  description = "The private IP address for each EC2 instance."
  value       = local.ec2_instance_private_ips
}
output "ec2_instance_public_ips" {
  description = "The public IP address for each EC2 instance (if applicable)."
  value       = local.ec2_instance_public_ips
}
output "ec2_instance_states" {
  description = "The current EC2 instance status for each Tableau Server instance, as of time of plan execution."
  value       = local.ec2_instance_states
}
output "ec2_remote_admin_commands" {
  description = "Command line command to connect to the Tableau Server instance(s) via RDP or SSH."
  value       = local.ec2_remote_admin_commands
}
output "ec2_windows_instance_passwords" {
  description = "The admin passwords for Windows instances (if applicable)."
  value       = module.windows_tableau_servers.windows_instance_passwords
}
output "ssh_private_key_filepath" {
  description = "Local path to private key file for connecting to the server via SSH."
  value       = var.ssh_private_key_filepath
}
output "summary" {
  description = "Summary of resources created by this module."
  value = <<EOF

Instances Launched:
${join("\n  ",
  [
    for s in flatten([module.linux_tableau_servers.instance_ids, module.windows_tableau_servers.instance_ids]) :
    join("\n", [
      "  - Instance ID:    ${s}",
      "    Public IP:      ${local.ec2_instance_public_ips[s]}",
      "    Private IP:     ${local.ec2_instance_private_ips[s]}",
      "    Tableau URL:    http://${local.ec2_instance_public_ips[s]}",
      "    TSM Admin URL:  http://${local.ec2_instance_public_ips[s]}:8850",
      "    Remote Admin:   ${local.ec2_remote_admin_commands[s]}",
      "    Admin User:     ${contains(keys(module.windows_tableau_servers.windows_instance_passwords), s) ? "Administrator:${module.windows_tableau_servers.windows_instance_passwords[s]}" : "tabadmin:tabadmin"}",
    ""])
])
}
EOF
}
