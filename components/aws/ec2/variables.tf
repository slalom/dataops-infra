##############################################
### Standard variables for all AWS modules ###
##############################################

variable "name_prefix" {
  description = "Standard `name_prefix` module input. (Prefix counts towards 64-character max length for certain resource types.)"
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
on the instance(s). By default this will default to only allow connections
from the terraform user's current IP address.
EOF
  default     = []
}
variable "admin_ports" {
  description = <<EOF
A map defining the admin ports which should be goverened by `admin_cidr`. Single ports
(e.g. '22') and port ranges (e.g. '0:65535') and both supported.
EOF
  type        = map
  default     = { "SSH" : "22" }
}
variable "app_cidr" {
  description = <<EOF
Optional. The IP address range(s) which should have access to the non-admin ports
(such as end-user http portal). If not set, this will default to allow incoming
connections from any IP address (['0.0.0.0/0']). In general, this should be omitted
unless the site has a VPN or other internal list of IP whitelist ranges.
EOF
  default     = ["0.0.0.0/0"]
}
variable "app_ports" {
  description = <<EOF
A map defining the end-user ports which should be goverened by `app_cidr`. Single ports
(e.g. '22') and port ranges (e.g. '0:65535') and both supported.
EOF
  type        = map
  default     = {}
}
variable "cluster_ports" {
  description = "A map defining which ports should be openen for instances to talk with one another."
  default     = {}
}
variable "ami_owner" {
  description = "The name or account number of the owner who publishes the AMI."
  default     = "amazon"
}
variable "ami_name_filter" {
  description = "A name filter used when searching for the EC2 AMI ('*' used as wildcard)."
  type        = string
}
variable "instance_type" {
  description = "The desired EC2 instance type."
  type        = string
}
variable "instance_storage_gb" {
  description = "The desired EC2 instance storage, in GB."
  default     = 100
}
variable "is_windows" {
  description = "True to launch a Windows instance, otherwise False."
  default     = false
}
variable "file_resources" {
  description = "List of files to needed on the instance (e.g. 'http://url/to/remote/file', '/path/to/local/file', '/path/to/local/file:renamed')"
  default     = []
}
variable "https_domain" {
  description = "If `use_https` = True, the https domain for secure web traffic."
  default     = ""
}
variable "num_instances" {
  description = "The number of EC2 instances to launch."
  default     = 1
}
variable "ssh_keypair_name" {
  description = "The name of a SSH key pair which has been uploaded to AWS. This is used to access Linux instances remotely."
  type        = string
}
variable "ssh_private_key_filepath" {
  description = "The local private key file for the SSH key pair which has been uploaded to AWS. This is used to access Linux instances remotely."
  type        = string
}
variable "use_https" {
  description = "True to enable https traffic on the instance."
  default     = false
}
variable "use_private_subnets" {
  description = <<EOF
If True, EC2 will use a private subnets and will require a NAT gateway to pull the docker
image, and for any outbound traffic. If False, tasks will use a public subnet and will
not require a NAT gateway. Note: a load balancer configuration may also be required in
order for EC2 instances to receive incoming traffic.
EOF
  type        = bool
  default     = false
}
