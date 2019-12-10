output "aws_creds_filepath" { value = local_file.aws_credentials_file.filename }
output "aws_default_region" { value = var.aws_region }
output "aws_user_access_key_masked" {
  value = "****************${substr(aws_iam_access_key.automation_user_key.id, 15, 4)}"
}
output "aws_user_name" { value = aws_iam_access_key.automation_user_key.user }
output "s3_bucket_name" { value = aws_s3_bucket.s3_metadata_bucket.bucket }
output "ssh_private_key_filenames" {
  value = [local_file.ssh_installed_private_key_path.filename, module.ssh_key_pair.private_key_filename]
}
output "ssh_public_key_filenames" {
  value = [local_file.ssh_installed_public_key_path.filename, module.ssh_key_pair.public_key_filename]
}
