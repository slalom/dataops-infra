output "aws_secret_secret_access_keys" {
  description = "Mapping of user IDs to their secret access keys (encrypted)."
  value = {
    for user in var.users :
    user => aws_iam_access_key.user_keys[user].encrypted_secret
  }
}

output "summary" {
  description = <<EOF
Standard Output. Human-readable summary of what was created
by the module and (when applicable) how to access those
resources.
EOF
  value = <<EOF
SFTP Users Summary:

 - ${try(
  join("\n\n - ", [
    for user in var.users :
    "${user}:\n${join("\n", [
      "   - ${user}",
      "     - private SSH key file: ${abspath(module.ssh_key_pair.private_key_filename)}",
      "     - public SSH key file:  ${abspath(module.ssh_key_pair.public_key_filename)}"
    ])}"
  ]),
"(error)")
}
EOF
}
