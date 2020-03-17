locals {
  # AMIs scraped from CloudFormation template here: https://aws.amazon.com/marketplace/pp/Matillion-Matillion-ETL-for-Snowflake/B073GRSSZD
  ami_per_region = {
    ap-northeast-1 = "ami-078373c32a9089b68"
    ap-northeast-2 = "ami-06490bfb567716b2f"
    ap-south-1     = "ami-01ea0879b082ad9a3"
    ap-southeast-1 = "ami-0ae72b074c4b9fb72"
    ap-southeast-2 = "ami-07344193c423c46b4"
    ca-central-1   = "ami-0624b4640eaad15e4"
    eu-central-1   = "ami-01de99d53f0cecc4c"
    eu-west-1      = "ami-02479a14183eba298"
    eu-west-2      = "ami-02c583b7e0596d8b6"
    eu-west-3      = "ami-07970146e979b45e7"
    sa-east-1      = "ami-03bb4c99cf29c40b1"
    us-east-1      = "ami-0038efa9aacf4c82a"
    us-east-2      = "ami-09e1c7a04745238b0"
    us-west-1      = "ami-069968da832441f80"
    us-west-2      = "ami-05eb13999bb3dec5b"
    us-gov-east-1  = "ami-f433d185"
    us-gov-west-1  = "ami-d3075db2"
  }
}
