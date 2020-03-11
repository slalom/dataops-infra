/*
* # AWS Secrets Manager
*
* `components/aws/secrets-manager`
*
* ## Overview
*
* This module takes as input a set of maps from variable names to secrets locations (in YAML or JSON). The module uploads those secrets to AWS Secrets Manager and returns the same map pointing to the IDs of new AWS Secrets manager locations. Those IDs (aka ARNs) can then safely be handed on to other resources which required access to those secrets.
*
* **Usage Notes:**
*
* * Any secrets locations which are already pointing to AWS secrets will simply be passed back through to the output with no changes.
* * For security reasons, this module does not accept inputs for secrets using the clear text of the secrets themselves. To properly use this module, first save the secrets to a YAML or JSON file which is excluded from source control.
*
* ## Usage Example
*
* **Sample inputs:**
*
* ```hcl
*   secrets_file_map = {
*     # These secret will be retrieved from the respective files and uploaded
*     # to AWS Secrets Manager:
*     MY_SAMPLE_1_username = "./.secrets/mysample1-creds.yml:username
*     MY_SAMPLE_1_password = "./.secrets/mysample1-creds.yml:password
*     MY_SAMPLE_2_username = "./.secrets/mysample2-creds.json:username
*     MY_SAMPLE_2_password = "./.secrets/mysample2-creds.json:password
*
*     # Because the paths starts with `arn://`, these secret are assumed to be
*     # already in AWS Secrets Manager and will not be uploaded:
*     SAMPLE_aws_access_key_id     = "arn:aws:secretsmanager:us-east-1::secret:aws_access_key_id-sqQDPG"
*     SAMPLE_aws_secret_access_key = "arn:aws:secretsmanager:us-east-1::secret:aws_secret_access_key-adf13"
*   }
* ```
*
* **Outputs from sample:**
*
* ```hcl
* {
*     # Newly created AWS Secrets Manager secrets:
*     MY_SAMPLE_1_username = "arn:aws:secretsmanager:us-east-1::secret:MY_SAMPLE_1_username-adf13"
*     MY_SAMPLE_1_password = "arn:aws:secretsmanager:us-east-1::secret:MY_SAMPLE_1_password-adf13"
*     MY_SAMPLE_2_username = "arn:aws:secretsmanager:us-east-1::secret:MY_SAMPLE_2_username-adf13"
*     MY_SAMPLE_2_password = "arn:aws:secretsmanager:us-east-1::secret:MY_SAMPLE_2_password-adf13"
*
*     # Secrets IDs passed through with no change:
*     SAMPLE_aws_access_key_id     = "arn:aws:secretsmanager:us-east-1::secret:aws_access_key_id-adf13"
*     SAMPLE_aws_secret_access_key = "arn:aws:secretsmanager:us-east-1::secret:aws_secret_access_key-adf13"
* }
* ```
*
*/

locals {
  secrets_names = toset(keys(var.secrets_map))
  existing_secrets_ids_map = {
    # filter existing map for secrets already stored in AWS secrets manager
    for secret_name, location in var.secrets_map :
    secret_name => location
    if replace(secret_name, ":secretsmanager:", "") != secret_name
  }
  new_secrets_map = {
    # raw secrets which have not yet been stored in AWS secrets manager
    for secret_name, location in var.secrets_map :
    # split the filename from the key name using the ':' delimeter and return the
    # secret value the file
    secret_name => yamldecode(
      file(split(":", location)[0])
    )[split(":", location)[1]]
    if replace(secret_name, ":secretsmanager:", "") == secret_name
  }
  merged_secrets_map = merge(
    local.existing_secrets_ids_map, {
      for created_name in keys(local.new_secrets_map) :
      created_name => aws_secretsmanager_secret.secrets[created_name].id
    }
  )
}

resource "aws_secretsmanager_secret" "secrets" {
  for_each   = toset(keys(local.new_secrets_map))
  name       = "${var.name_prefix}${each.key}"
  kms_key_id = var.kms_key_id
}

resource "aws_secretsmanager_secret_version" "secrets_value" {
  for_each      = local.new_secrets_map
  secret_id     = aws_secretsmanager_secret.secrets[each.key].id
  secret_string = each.value
}
