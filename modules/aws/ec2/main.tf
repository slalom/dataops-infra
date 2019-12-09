data "aws_availability_zones" "myAZs" {}
data "http" "icanhazip" { url = "http://ipv4.icanhazip.com" }
# TODO: Detect EC2 Pricing
# data "http" "ec2_base_pricing_js" { 
#   url = "http://a0.awsstatic.com/pricing/1/ec2/linux-od.min.js"
#   request_headers = {
#     "Accept" = "application/javascript"
#   }
# }
# resource "null_resource" "ec2_base_pricing_js" { 
#   provisioner "local-exec" {
#     command = "curl http://aws.amazon.com/ec2/pricing/"
#     # curl http://aws.amazon.com/ec2/pricing/ 2>/dev/null | grep 'model:' | sed -e "s/.*'\(.*\)'.*/http:\\1/"
#   }
# }


locals {
  project_shortname        = substr(var.name_prefix, 0, length(var.name_prefix) - 1)
  my_ip                    = "${chomp(data.http.icanhazip.body)}"
  my_ip_cidr               = "${chomp(data.http.icanhazip.body)}/32"
  admin_cidr               = flatten([local.my_ip_cidr, var.admin_cidr])
  default_cidr             = length(var.default_cidr) == 0 ? local.admin_cidr : var.default_cidr
  ssh_key_dir              = pathexpand("~/.ssh")
  ssh_public_key_filepath  = "${local.ssh_key_dir}/${lower(var.name_prefix)}prod-ec2keypair.pub"
  ssh_private_key_filepath = "${local.ssh_key_dir}/${lower(var.name_prefix)}prod-ec2keypair.pem"
  pricing_regex            = chomp(
<<EOF
${var.aws_region}\\\"\\X*${replace(var.instance_type, ".", "\\.")}\\X*prices\\X*USD:\\\"(\\X*)\\\"
EOF
)
  # TODO: Detect EC2 Pricing
  # price_per_instance_hr    = (
  #   length(regexall(local.pricing_regex, data.http.ec2_base_pricing_js)) == 0 ? "n/a" : 
  #   regex(local.pricing_regex, data.http.ec2_base_pricing_js)[0]
  # )
  chocolatey_install_win   = <<EOF
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))" && SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"
EOF
}

data "aws_ami" "ec2_ami" {
  owners      = [var.ami_owner] # Canonical
  most_recent = true
  filter {
    name   = "name"
    values = [var.ami_name_filter]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

resource "aws_security_group" "ec2_sg_admin_ports" {
  name_prefix = "${var.name_prefix}SecurityGroupForAdminPorts"
  description = "allow admin traffic from whitelisted IPs"
  vpc_id      = var.vpc_id
  tags        = { project = local.project_shortname }
  dynamic "ingress" {
    for_each = var.admin_ports
    content {
      protocol    = "tcp"
      description = ingress.key
      from_port   = tonumber(split(":", ingress.value)[0])
      to_port     = length(split(":", ingress.value)) > 1 ? tonumber(split(":", ingress.value)[1]) : tonumber(ingress.value)
      cidr_blocks = local.default_cidr
    }
  }
}

resource "aws_security_group" "ec2_sg_app_ports" {
  name_prefix = "${var.name_prefix}SecurityGroupForAppPorts"
  description = "allow app traffic on whitelisted ports"
  vpc_id      = var.vpc_id
  tags        = { project = local.project_shortname }
  dynamic "ingress" {
    for_each = var.app_ports
    content {
      protocol    = "tcp"
      description = ingress.key
      from_port   = tonumber(split(":", ingress.value)[0])
      to_port     = length(split(":", ingress.value)) > 1 ? tonumber(split(":", ingress.value)[1]) : tonumber(ingress.value)
      cidr_blocks = local.default_cidr
    }
  }
}

resource "aws_security_group" "ec2_sg_allow_outbound" {
  name_prefix = "${var.name_prefix}SecurityGroupForOutbound"
  description = "allow all outbound traffic"
  vpc_id      = var.vpc_id
  tags        = { project = local.project_shortname }
  egress {
    protocol    = "tcp"
    from_port   = "0"
    to_port     = "65535"
    cidr_blocks = var.default_cidr
  }
}

# resource "aws_key_pair" "mykey" {
#   key_name   = "${var.name_prefix}ec2-keypair"
#   public_key = file(local.ssh_public_key_filepath)
# }

resource "aws_instance" "ec2_instances" {
  count                   = var.num_instances
  ami                     = data.aws_ami.ec2_ami.id
  instance_type           = var.instance_type
  key_name                = var.ssh_key_name
  subnet_id               = var.subnet_id
  user_data               = var.is_windows ? local.userdata_win : local.userdata_lin
  get_password_data       = var.is_windows
  ebs_optimized           = true
  monitoring              = true
  disable_api_termination = false
  tags = {
    name    = "${var.name_prefix}TableauServer-Linux"
    project = local.project_shortname
  }
  vpc_security_group_ids = [
    aws_security_group.ec2_sg_admin_ports.id,
    aws_security_group.ec2_sg_allow_outbound.id,
    aws_security_group.ec2_sg_app_ports.id
  ]
  root_block_device {
    volume_type = "gp2"
    volume_size = var.instance_storage_gb
    encrypted   = true
  }
  lifecycle {
    create_before_destroy = true
    ignore_changes        = [tags]
  }
}

locals {
  userdata_lin = <<EOF
#!/bin/bash
export HOMEDIR=/home/ubuntu/tableau
mkdir -p $HOMEDIR
cd $HOMEDIR
sudo chmod 777 $HOMEDIR
echo "" > ___BOOSTSTRAP_STARTED_
export PROJECT=${local.project_shortname}
${var.use_https == false ? "" : "export HTTPS_DOMAIN=${var.https_domain}"}
${join("\n",
  [for x in var.file_resources :
    substr(x, 0, 4) == "http"
    ? "curl ${split(":", x)[0]} > ${length(split(":", x)) == 1 ? basename(x) : split(":", x)[1]}"
    : "echo ${base64encode(file("${path.module}/${split(":", x)[0]}"))} | base64 --decode > ${length(split(":", x)) == 1 ? basename(x) : split(":", x)[1]}"
  ]
)}
echo "" > __BOOTSTRAP_COMPLETE_
echo "" > __USERDATA_SCRIPT_STARTED_
sudo chmod -R 777 $HOMEDIR
./userdata_lin.sh
echo "" > _USERDATA_SCRIPT_COMPLETE_
EOF
}

locals {
  userdata_win = <<EOF
<script>
set PROJECT=${local.project_shortname}
${var.use_https == false ? "" : "set HTTPS_DOMAIN=${var.https_domain}"}
${local.chocolatey_install_win}
set HOMEDIR=C:\Users\Administrator\tableau
choco install -y curl
mkdir %HOMEDIR% 2> NUL
cd %HOMEDIR%
echo "" > ___BOOSTSTRAP_STARTED_
${join("\n",
  [for x in var.file_resources :
    substr(x, 0, 4) == "http"
    ? "curl ${x} > ${length(split(":", x)) == 1 ? basename(x) : split(":", x)[1]}"
    : "echo ${base64encode(file("${path.module}/${x}"))} > ${basename(x)}.b64 && certutil -decode ${basename(x)}.b64 ${length(split(":", x)) == 1 ? basename(x) : split(":", x)[1]} & del ${basename(x)}.b64"
  ]
)}
dism.exe /online /import-defaultappassociations:defaultapps.xml
echo "" > __BOOTSTRAP_COMPLETE_
echo "" > __USERDATA_SCRIPT_STARTED_
userdata_win.bat
cd %HOMEDIR%
echo "" > _USERDATA_SCRIPT_COMPLETE_
</script>
<persist>true</persist>
EOF
}
