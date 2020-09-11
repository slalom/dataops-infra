output "ssh_keypair_name" {
  description = "The SSH key name for EC2 remote access."
  value       = length(aws_instance.ec2_instances) == 0 ? "n/a" : aws_instance.ec2_instances[0].key_name
}
output "ssh_private_key_path" {
  description = "The local path to the private key file used for EC2 remote access."
  value       = var.ssh_private_key_filepath
}
output "instance_id" {
  description = "The instance ID (if `num_instances` == 1)."
  value       = length(aws_instance.ec2_instances) == 0 ? "n/a" : aws_instance.ec2_instances[0].id
}
output "instance_ids" {
  description = "The list of instance ID created."
  value       = aws_instance.ec2_instances[*].id
}
output "public_ip" {
  description = "The public IP address (if applicable, and if `num_instances` == 1)"
  value       = length(aws_instance.ec2_instances) == 0 ? "n/a" : aws_instance.ec2_instances[0].public_ip
}
output "public_ips" {
  description = "A map of EC2 instance IDs to public IP addresses (if applicable)."
  value = {
    for s in aws_instance.ec2_instances :
    s.id => s.public_ip
  }
}
output "private_ip" {
  description = "The private IP address (if `num_instances` == 1)"
  value       = length(aws_instance.ec2_instances) == 0 ? "n/a" : aws_instance.ec2_instances[0].private_ip
}
output "private_ips" {
  description = "A map of EC2 instance IDs to private IP addresses."
  value = {
    for s in aws_instance.ec2_instances :
    s.id => s.private_ip
  }
}
output "instance_state" {
  description = "The state of the instance at time of apply (if `num_instances` == 1)."
  value       = length(aws_instance.ec2_instances) == 0 ? "n/a" : aws_instance.ec2_instances[0].instance_state
}
output "instance_states" {
  description = "A map of instance IDs to the state of each instance at time of apply."
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
        "ssh -o StrictHostKeyChecking=no -i \"${coalesce(var.ssh_private_key_filepath, "n\\a")}\" ubuntu@${s.public_ip}"
      )
    })
  )
}
output "windows_instance_passwords" {
  description = "A map of instance IDs to Windows passwords (if applicable)."
  value       = local.windows_instance_passwords
}
output "remote_admin_commands" {
  description = "A map of instance IDs to command-line strings which can be used to connect to each instance."
  value       = local.remote_admin_commands
}
