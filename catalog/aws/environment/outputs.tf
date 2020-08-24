output "summary" {
  description = "Summary of resources created by this module."
  value       = <<EOF


Environment summary:

  VPC ID:          ${module.vpc.vpc_id}
  AWS Region:      ${var.aws_region}
  Private Subnets: ${join(",", module.vpc.private_subnets)}
  Public Subnets:  ${join(",", module.vpc.public_subnets)}
  User Switch Command:
   - Linux/Mac:     export AWS_SHARED_CREDENTIALS_FILE=${local.aws_credentials_file}
   - Windows (cmd): SET AWS_SHARED_CREDENTIALS_FILE=${local.aws_credentials_file}
   - Windows (PS):  $Env:AWS_SHARED_CREDENTIALS_FILE = ${local.aws_credentials_file}

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
output "public_route_table" {
  description = "The ID of the route table for public subnets."
  value       = module.vpc.public_route_table
}
output "private_route_table" {
  description = "The ID of the route table for private subnets."
  value       = module.vpc.private_route_table
}
