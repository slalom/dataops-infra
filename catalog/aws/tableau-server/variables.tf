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

variable "admin_cidr" {
  description = <<EOF
Optional. The IP address range(s) which should have access to the admin
on the Tableau Server instances. By default this will default to only allow
connections from the terraform user's current IP address.
EOF
  default     = []
}
variable "app_cidr" {
  description = <<EOF
Optional. The IP address range(s) which should have access to the view the
Tableau Server web instance (excluding the TMS admin portal and other admin
ports). If not set, this will default to allow incoming connections from
any IP address (['0.0.0.0/0']). In general, this should be omitted unless the
site has a VPN or other internal list of IP whitelist ranges.
EOF
  default     = ["0.0.0.0/0"]
}
variable "ec2_instance_type" {
  description = "Optional. Overrides the Tableau Server instance type."
  default     = "m5.4xlarge"
}
variable "ec2_instance_storage_gb" {
  description = "The amount of storage to provision on each instance, in GB."
  default     = 100
}
variable "linux_use_https" {
  description = "True if the Linux instances should use HTTPS."
  default     = false
}
variable "linux_https_domain" {
  description = "The https domain if the Linux instances should use HTTPS."
  default     = ""
}
variable "num_linux_instances" {
  description = "The number of Tableau Server instances to create on Linux."
  default     = 1
}
variable "num_windows_instances" {
  description = "The number of Tableau Server instances to create on Windows."
  default     = 0
}
variable "registration_file" {
  description = "A path to a local or remote file for Tableau registration."
  default     = "../../.secrets/registration.json"
}
variable "windows_use_https" {
  description = "True if the Windows instances should use HTTPS."
  default     = false
}
variable "windows_https_domain" {
  description = "The https domain if the Windows instances should use HTTPS."
  default     = ""
}
variable "ssh_keypair_name" {
  description = "Optional. Name of SSH Keypair in AWS."
  type        = string
  default     = null
}
variable "ssh_private_key_filepath" {
  description = "Optional. Path to a valid public key for SSH connectivity."
  type        = string
  default     = null
}

variable "use_private_subnets" {
  description = <<EOF
If True, tasks will use a private subnet and will require a NAT gateway to pull the docker
image, and for any outbound traffic. If False, tasks will use a public subnet and will
not require a NAT gateway. Note: a load balancer configuration will also be required in
order to forward incoming traffic to the Tableau Server instances.
EOF
  type        = bool
  default     = false
}
