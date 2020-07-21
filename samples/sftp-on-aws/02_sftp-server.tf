output "sftp_server_summary" { value = module.sftp_server.summary }
module "sftp_server" {
  # BOILERPLATE HEADER (NO NEED TO CHANGE):
  source        = "../../catalog/aws/sftp"
  name_prefix   = local.name_prefix
  resource_tags = local.resource_tags
  environment   = module.env.environment

  # ADD OR MODIFY CONFIGURATION HERE:

  # local_metadata_path     = "./sample-taps" # For most projects, this will be: "../../data/taps"
  # data_lake_type          = "S3"
  # data_lake_metadata_path = "s3://${module.data_lake_on_aws.s3_metadata_bucket}"
  # data_lake_storage_path  = "s3://${module.data_lake_on_aws.s3_data_bucket}/data/raw"
}
