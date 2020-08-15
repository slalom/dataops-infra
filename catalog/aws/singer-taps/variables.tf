##############################################
### Standard variables for all AWS modules ###
##############################################

variable "name_prefix" {
  description = "Standard `name_prefix` module input."
  type        = string
}
variable "environment" {
  description = "Standard `environment` module input."
  type = object({
    vpc_id          = string
    aws_region      = string
    public_subnets  = list(string)
    private_subnets = list(string)
  })
}
variable "resource_tags" {
  description = "Standard `resource_tags` module input."
  type        = map(string)
}

########################################
### Custom variables for this module ###
########################################

variable "local_metadata_path" {
  description = "The local folder which countains tap definitions files: `{tap-name}.rules.txt` and `{tap-name}.plan.yml`"
  type        = string
}
variable "data_lake_type" {
  description = "Specify `S3` if loading to an S3 data lake, otherwise leave blank."
  default     = null
}
variable "data_lake_metadata_path" {
  description = <<EOF
The remote folder for storing tap definitions files.
Currently only S3 paths (s3://...) are supported.
EOF
  type        = string
}
variable "data_lake_storage_path" {
  description = <<EOF
The root path where files should be stored in the data lake.
Note:
 - Currently only S3 paths (S3://...) are supported.
 - You must specify `target` or `data_lake_storage_path` but not both.
 - This path will be combined with the value provided in `data_file_naming_scheme`.
EOF
  type        = string
  default     = null
}
variable "data_file_naming_scheme" {
  description = <<EOF
The naming pattern to use when landing new files in the data lake. Allowed variables are:
`{tap}`, `{table}`, `{version}`, and `{file}`. This value will be combined with the root
data lake path provided in `data_lake_storage_path`."
EOF
  type        = string
  default     = "{tap}/{table}/v{version}/{file}"
}
variable "state_file_naming_scheme" {
  description = <<EOF
The naming pattern to use when writing or updating state files. State files keep track of
data recency and are necessary for incremental loading. Allowed variables are:
`{tap}`, `{table}`, `{version}`, and `{file}`"
EOF
  type        = string
  default     = "{tap}/{table}/state/{tap}-{table}-v{version}-state.json"
}
variable "taps" {
  description = <<EOF
A list of objects with the keys `id` (the name of the tap without the 'tap-' prefix),
`settings` (a map of tap settings to their desired values), and `secrets` (same as
`settings` but mapping setting names to the location of the secret and not the secret
values themselves)
EOF
  type = list(object({
    id       = string
    settings = map(string)
    secrets  = map(string)
  }))
}
variable "target" {
  description = <<EOF
The definition of which target to load data into.
Note: You must specify `target` or `data_lake_storage_path` but not both.
EOF
  type = object({
    id       = string
    settings = map(string)
    secrets  = map(string)
  })
  default = null
}
variable "scheduled_sync_times" {
  description = "A list of one or more daily sync times in `HHMM` format. E.g.: `0400` for 4am, `1600` for 4pm"
  type        = list(string)
  default     = []
}
variable "scheduled_timezone" {
  description = <<EOF
The timezone used in scheduling.
Currently the following codes are supported: PST, PDT, EST, UTC
EOF
  default     = "PT"
}
variable "container_image" {
  description = "Optional. Override the docker image with a custom-managed image."
  default     = null
}
variable "container_entrypoint" {
  description = "Optional. Override the docker image's entrypoint."
  default     = null
}
variable "container_command" {
  description = "Optional. Override the docker image's command."
  default     = null
}
variable "container_num_cores" {
  description = "Optional. Specify the number of cores to use in the container."
  default     = 0.5
}
variable "container_ram_gb" {
  description = "Optional. Specify the amount of RAM to be available to the container."
  default     = 1
}
variable "num_retries" {
  description = "Optional. The number of retries to attempt if the task fails."
  default     = 0
}
variable "timeout_hours" {
  description = "Optional. The number of hours before the sync task is canceled and retried."
  type        = number
  default     = 48
}
variable "pipeline_version_number" {
  description = <<EOF
Optional. (Default="1") Specify a pipeline version number when there are breaking changes which require
isolation. Note if you want to avoid overlap between versions, be sure to (1) cancel the
previous version and (2) specify a `start_date` on the new version which is not duplicative
of the previously covered time period.
EOF
  type        = string
  default     = "1"
}
variable "container_args" {
  type        = list(string)
  description = "Optional. A list of additional args to send to the container."
  default     = ["--config_file=False", "--target_config_file=False"]
}
variable "use_private_subnet" {
  description = <<EOF
If True, tasks will use a private subnet and will require a NAT gateway to pull the docker
image, and for any outbound traffic. If False, tasks will use a public subnet and will
not require a NAT gateway.
EOF
  type        = bool
  default     = false
}
