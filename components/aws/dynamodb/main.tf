/*
* DynamoDB is AWS's key-value and document NoSQL database. Data is stored in DynamoDB Tables.
*/

resource "aws_dynamodb_table" "dynamodb-table" {
  name         = "${var.name_prefix}metadata-store"
  tags         = var.resource_tags
  billing_mode = var.billing_mode
  hash_key     = var.primary_key
  attribute {
    name = var.primary_key
    type = "S"
  }
}
