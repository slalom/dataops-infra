# Infrastructure Catalog Module: `Data Lake Users`

This module manages users, groups, KMS keys, and data lake permissions.

## Input Variables

* **name_prefix** - Standard input pass-through.
* **data_bucket** - Standard input pass-through.
* **resource_tags** - Standard input pass-through.
* **group_permissions** - Mapping of group names to list of objects containing the applicable permissions.
* **users** - A unique list (set) of user IDs.
* **user_groups** - "A mapping of user IDs to group name.
* **admin_keybase_id** - The default keybase.io user ID to use for PGP password encryption.

## Output Variables

* **aws_secret_secret_access_keys** - Mapping of user IDs to their secret access keys (encrypted).
* **summary** - Standard Output. Human-readable summary of what was created by the module and (when applicable) how to access those resources.
