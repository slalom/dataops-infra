output "summary" {
  value = <<EOF


Environment summary:

  VPC ID:          ${module.vpc.vpc_id}
  AWS Region:      ${var.aws_region}
  Private Subnets: ${join(",", module.vpc.private_subnets)}
  Public Subnets:  ${join(",", module.vpc.public_subnets)}
  User Switch Cmd: ${coalesce(try(local.aws_user_switch_cmd, "n/a (error)"), "n/a")}

EOF
}

output "environment" {
  value = {
    vpc_id          = module.vpc.vpc_id
    aws_region      = var.aws_region
    private_subnets = module.vpc.private_subnets
    public_subnets  = module.vpc.public_subnets
  }
}

output "aws_credentials_file" { value = local.aws_credentials_file }
output "is_windows_host" { value = local.is_windows_host }
output "user_home" { value = local.user_home }
output "ssh_private_key_filename" { value = module.ssh_key_pair.private_key_filename }
output "ssh_public_key_filename" { value = module.ssh_key_pair.public_key_filename }
