output "ssh_key_name" { value = length(aws_instance.ec2_instances) == 0 ? "n/a" : aws_instance.ec2_instances[0].key_name }
output "ssh_public_key_path" { value = local.ssh_public_key_filepath }
output "ssh_private_key_path" { value = local.ssh_private_key_filepath }
output "instance_id" { value = length(aws_instance.ec2_instances) == 0 ? "n/a" : aws_instance.ec2_instances[0].id }
output "instance_ids" { value = aws_instance.ec2_instances[*].id }
# TODO: Detect EC2 Pricing
# output "instance_hr_list_price" { value = local.price_per_instance_hr }
output "public_ip" { value = length(aws_instance.ec2_instances) == 0 ? "n/a" : aws_instance.ec2_instances[0].public_ip }
output "public_ips" {
  value = {
    for s in aws_instance.ec2_instances :
    s.id => s.public_ip
  }
}
output "private_ip" { value = length(aws_instance.ec2_instances) == 0 ? "n/a" : aws_instance.ec2_instances[0].private_ip }
output "private_ips" {
  value = {
    for s in aws_instance.ec2_instances :
    s.id => s.private_ip
  }
}
output "instance_state" { value = length(aws_instance.ec2_instances) == 0 ? "n/a" : aws_instance.ec2_instances[0].instance_state }
output "instance_states" {
  value = {
    for s in aws_instance.ec2_instances :
    s.id => s.instance_state
  }
}
locals {
  windows_instance_passwords = (
    # returns a map of instance IDs to windows passwords
    # returns null if is_windows == false
    # returns null also if no private ssh key is available
    var.is_windows == false ? null :
    var.num_instances == 0 ? {} :
    {
      for s in aws_instance.ec2_instances :
      s.id => (
        length(s.password_data) == 0 ? "n/a" :
        fileexists(var.ssh_private_key_filepath) == false ? "n/a" :
        rsadecrypt(aws_instance.ec2_instances[0].password_data, file(var.ssh_private_key_filepath))
      )
    }
  )
  remote_admin_commands = (
    # returns a map of instance IDs to remote connect commands (ssh for linux, rdp for windows)
    var.num_instances == 0 ? {} :
    tomap({
      for s in aws_instance.ec2_instances :
      s.id => (
        var.is_windows == true ?
        "cmdkey /generic:TERMSRV/${s.public_ip} /user:Administrator /pass:\"${local.windows_instance_passwords[s.id]}\" && mstsc /v:${s.public_ip} /w:1100 /h:900" :
        "ssh -o StrictHostKeyChecking=no -i \"${local.ssh_private_key_filepath}\" ubuntu@${s.public_ip}"
      )
    })
  )
}
output "windows_instance_passwords" {
  value = local.windows_instance_passwords
}
output "remote_admin_commands" {
  value = local.remote_admin_commands
}
