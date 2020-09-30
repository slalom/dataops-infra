locals {
  storage_container_names = module.containers.container_names
  table_storage_names     = module.table_storage.table_storage_names
  queue_storage_names     = module.queue_storage.queue_storage_names
}

output "summary" {
  description = "Summary of resources created by this module."
  value       = <<EOF

Storage Summary:
  - Container Name(s):
  ${"\t"}${
    coalesce(join("\n\t",
      [
        for container_name in local.storage_container_names :
        "${container_name}"
      ]
    ), "(none)")
  }

  - Table Name(s):
  ${"\t"}${
    coalesce(join("\n\t",
      [
        for table_name in local.table_storage_names :
        "${table_name}"
      ]
    ), "(none)")
  }

  - Queue Name(s):
  ${"\t"}${
    coalesce(join("\n\t",
      [
        for queue_name in local.queue_storage_names :
        "${queue_name}"
      ]
    ), "(none)")
  }


EOF
}

output "storage_container_names" {
  description = "The Storage Container name value(s) of the newly created container(s)."
  value       = local.storage_container_names
}

output "table_storage_names" {
  description = "The Table Storage name value(s) of the newly created table(s)."
  value       = local.table_storage_names
}

output "queue_storage_names" {
  description = "The Queue Storage name value(s) of the newly created table(s)."
  value       = local.queue_storage_names
}
