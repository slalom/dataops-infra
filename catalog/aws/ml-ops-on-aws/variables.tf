variable "name_prefix" { 
  type = string 
}

variable "s3_bucket_name" { 
  type = string 
}

variable "data_folder" { 
  type = string 
  default = "source/data" 
}

variable "data_s3_path" {
  type    = string
  default = "data"
}

variable "environment" {
  type = object({
    vpc_id          = string
    aws_region      = string
    public_subnets  = list(string)
    private_subnets = list(string)
  })
}

variable "resource_tags" {
  type    = map
  default = {}
}
