output "sftp_server_arn" {
  description = "The ARN of the Transfer Server."
  value       = aws_transfer_server.sftp_server.arn
}

output "sftp_server_id" {
  description = "The ARN of the Transfer Server."
  value       = aws_transfer_server.sftp_server.id
}

output "sftp_endpoint" {
  description = "The endpoint used to connect to the SFTP server. E.g. `s-12345678.server.transfer.REGION.amazonaws.com`"
  value       = aws_transfer_server.sftp_server.endpoint
}

output "sftp_host_fingerprint" {
  description = "The message-digest algorithm (MD5) hash of the server's host key."
  value       = aws_transfer_server.sftp_server.host_key_fingerprint
}

output "summary" {
  description = "Connection information for the SFTP server."
  value       = <<EOF

SFTP Summary:

  SFTP endpoint:    ${aws_transfer_server.sftp_server.endpoint}
  Host fingerprint: ${aws_transfer_server.sftp_server.host_key_fingerprint}
EOF
  # Port:             ${aws_transfer_server.sftp_server.port}
}
