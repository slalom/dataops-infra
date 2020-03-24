output "summary" {
  description = "Summary of resources created by this module."
  value       = <<EOF


Environment summary:

  VPC ID:          ${module.vpc.vpc_id}
  AWS Region:      ${var.aws_region}
  Private Subnets: ${join(",", module.vpc.private_subnets)}
  Public Subnets:  ${join(",", module.vpc.public_subnets)}
  User Switch Cmd: ${coalesce(try(local.aws_user_switch_cmd, "n/a (error)"), "n/a")}

EOF
}

output "environment" {
  description = "The `environment` object to be passed as a standard input to other Infrastructure Catalog modules."
  value = {
    vpc_id          = module.vpc.vpc_id
    aws_region      = var.aws_region
    private_subnets = module.vpc.private_subnets
    public_subnets  = module.vpc.public_subnets
  }
}
output "aws_credentials_file" {
  description = "Path to AWS credentials file for the project."
  value       = local.aws_credentials_file
}
output "is_windows_host" {
  description = "True if running on a Windows machine, otherwise False."
  value       = local.is_windows_host
}
output "user_home" {
  description = "Path to the admin user's home directory."
  value       = local.user_home
}
output "ssh_private_key_filename" {
  description = "Path to private key for SSH connections."
  value       = module.ssh_key_pair.private_key_filename
}
output "ssh_public_key_filename" {
  description = "Path to public key for SSH connections."
  value       = module.ssh_key_pair.public_key_filename
}
