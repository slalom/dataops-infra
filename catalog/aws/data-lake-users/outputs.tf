# output "aws_secret_secret_access_keys" {
#   description = "Mapping of user IDs to their secret access keys (encrypted)."
#   value = {
#     for user in var.users :
#     user => aws_iam_access_key.user_keys[user].encrypted_secret
#   }
# }

# output "summary" {
#   description = <<EOF
# Standard Output. Human-readable summary of what was created
# by the module and (when applicable) how to access those
# resources.
# EOF
#   value = <<EOF
# Data Lake Users Summary:

#  - ${
#   try(
#     join("\n\n - ", [
#       for user in var.users :
#       "${user}:\n${join("\n", [
#         "   - AWS Access Key ID:    ${try(aws_iam_access_key.user_keys[user].id, "(error)")}",
#         "   - Secret Key Retrieval: keybase pgp decrypt --infile ${try(local_file.encrypted_secret_key_files[user].filename, "(error)")}"
#       ])}"
#     ])
#     )}

# Data Lake Groups:
#  - ${try(
#     join("\n\n - ", [
#       for group in local.group_names :
#       "${group}:\n${join("\n", [
#         "   - KMS Key Alias: ${aws_kms_alias.group_kms_key_alias[group].id}"
#       ])}"
#     ])
# )}
# EOF
# }
