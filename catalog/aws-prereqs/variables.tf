variable "aws_region" {
  description = "Enter your desired AWS region (e.g. 'us-east-2') or leave blank to attempt to load from settings."
}
variable "project_shortname" {
  description = "Enter your desired project shortname with no spaces (e.g. 'MyTest', 'AJTableau') or leave blank to attempt to load from settings."
}
variable "terraform_basic_account_access_key" {
  description = "Enter the Access Key ID for your Terraform-Basic-Account on AWS. If you have not already done so, please log into AWS, navigate to the 'IAM' service, and create a new user. When prompted, check the box to allow 'Programmatic access' and then select the option to 'Attach existing policies directly' with the following policies attached: 'AmazonS3FullAccess', 'EC2FullAccess', 'IAMFullAccess', and 'AWSKeyManagementServicePowerUser'. Enter the resulting credentials here, beginning with the account key id here:"
}
variable "terraform_basic_account_secret_key" {
  description = "Enter the Secret Key for your Terraform-Basic-Account on AWS. This account should be created with the following policies attached: 'AmazonS3FullAccess', 'IAMFullAccess', and 'AWSKeyManagementServicePowerUser'"
}
