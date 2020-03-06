module "ml-ops-on-aws" {
  #source        = "git::https://github.com/slalom-ggp/dataops-infra.git//catalog/aws/data-lake?ref=master"
  source         = "../../catalog/aws/ml-ops-on-aws"
  name_prefix    = local.name_prefix
  environment    = module.env.environment
  resource_tags  = local.resource_tags

  # Training data source and upload
  s3_bucket_name = module.s3_store_and_lambdas.s3_data_bucket

  /* OPTIONAL - CHANGE PATHS BELOW:

  # data_s3_path = "data"
  # data_folder  = "source/data" 

  */
}

output "summary" {
  value = <<EOF


Step Functions summary:
 ${module.ml-ops-on-aws.summary}

S3 summary:

 S3 Bucket Name: ${module.s3_store_and_lambdas.s3_data_bucket}
EOF
}