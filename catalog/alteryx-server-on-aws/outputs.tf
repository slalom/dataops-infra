output "ec2_instance_ids" { value = local.ec2_instance_ids }
output "ec2_instance_public_ips" { value = local.ec2_instance_public_ips }
output "ec2_instance_private_ips" { value = local.ec2_instance_private_ips }
output "ec2_instance_states" { value = local.ec2_instance_states }
output "ec2_remote_admin_commands" { value = local.ec2_remote_admin_commands }
output "ec2_windows_instance_passwords" { value = module.windows_tableau_servers.windows_instance_passwords }
# TODO: Detect EC2 Pricing
# output "ec2_instance_hr_base_price" {
#   # estimated base price of the (linux) instance type, excluding upcharge for Windows instance and excluding any special pricing or reservation discounts.
#   value = module.linux_tableau_servers.instance_hr_list_price
# }
output "summary" {
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
