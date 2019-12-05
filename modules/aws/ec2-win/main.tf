data "aws_availability_zones" "myAZs" {}
data "http" "icanhazip" { url = "http://ipv4.icanhazip.com" }

locals {
  project_shortname = substr(var.name_prefix, 0, length(var.name_prefix) - 1)
  my_ip             = "${chomp(data.http.icanhazip.body)}"
  my_ip_cidr        = "${chomp(data.http.icanhazip.body)}/32"
  admin_cidr        = flatten([local.my_ip_cidr, var.admin_cidr])
  default_cidr      = length(var.default_cidr) == 0 ? local.admin_cidr : var.default_cidr
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
  name        = "${var.name_prefix}SecurityGroupForAdminPorts"
  description = "allow admin traffic from whitelisted IPs"
  vpc_id      = var.vpc_id
  tags        = { project = local.project_shortname }
  dynamic "ingress" {
    for_each = var.admin_ports
    content {
      protocol    = "tcp"
      description = ingress.key
      from_port   = ingress.value
      to_port     = length(split(ingress.value, ":")) > 1 ? split(ingress.value)[1] : ingress.value
      cidr_blocks = local.default_cidr
    }
  }
}
resource "aws_security_group" "ec2_sg_app_ports" {
  name        = "${var.name_prefix}SecurityGroupForAppPorts"
  description = "allow app traffic on whitelisted ports"
  vpc_id      = var.vpc_id
  tags        = { project = local.project_shortname }
  dynamic "ingress" {
    for_each = var.app_ports
    content {
      protocol    = "tcp"
      description = ingress.key
      from_port   = ingress.value
      to_port     = length(split(ingress.value, ":")) > 1 ? split(ingress.value)[1] : ingress.value
      cidr_blocks = local.default_cidr
    }
  }
}

resource "aws_security_group" "ec2_sg_allow_outbound" {
  name        = "${var.name_prefix}SecurityGroupForOutbound"
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

locals {
  ssh_key_dir              = pathexpand("~/.ssh")
  ssh_public_key_filepath  = "${local.ssh_key_dir}/${lower(var.name_prefix)}prod-ec2keypair.pub"
  ssh_private_key_filepath = "${local.ssh_key_dir}/${lower(var.name_prefix)}prod-ec2keypair.pem"
  chocolatey_install_win   = <<EOF
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))" && SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"
EOF
  registration_install_cmd_win = (
    substr(var.registration_file, 0, 4) == "http" ?
    "curl \"${var.registration_file}\" > " :
    "echo ${base64encode(file(var.registration_file))} > tmp9.b64 && certutil -decode tmp9.b64 "
  )
  registration_install_cmd_lin = (
    substr(var.registration_file, 0, 4) == "http" ?
    "curl ${var.registration_file} > " :
    "echo ${base64encode(file(var.registration_file))} | base64 --decode > "
  )
}

locals {
  userdata_lin = <<EOF
#!/bin/bash
mkdir -p /home/ubuntu/tableau
cd /home/ubuntu/tableau
sudo chmod 777 /home/ubuntu/tableau
echo "" > ___BOOSTSTRAP_STARTED_
export PROJECT=${local.project_shortname}
${var.use_https == false ? "" : "export HTTPS_DOMAIN=${var.https_domain}"}
${join("\n", [for x in local.lin_files :
  "echo ${base64encode(file("${path.module}/${x}"))} | base64 --decode > ${basename(x)}"
])}
${local.registration_install_cmd_lin} registration.json
echo "" > __BOOTSTRAP_COMPLETE_
echo "" > __USERDATA_SCRIPT_STARTED_
sudo chmod -R 777 /home/ubuntu/tableau
./userdata_lin.sh
echo "" > _USERDATA_SCRIPT_COMPLETE_
EOF

userdata_win = <<EOF
<script>
set PROJECT=${local.project_shortname}
${var.use_https == false ? "" : "set HTTPS_DOMAIN=${var.https_domain}"}
${local.chocolatey_install_win}
choco install -y curl
mkdir C:\Users\Administrator\tableau 2> NUL
cd C:\Users\Administrator\tableau
echo "" > ___BOOSTSTRAP_STARTED_
${join("\n",
  [for x in local.file_resources :
    substr(var.registration_file, 0, 4) == "http" 
    ? "curl ${var.registration_file} > ${length(split(x, ":")) == 1 ? basename(x) : split(x, ":")[1]}"
    : "echo ${base64encode(file("${path.module}/${x}"))} > ${basename(x)}.b64 && certutil -decode ${basename(x)}.b64 ${length(split(x, ":")) == 1 ? basename(x) : split(x, ":")[1]} & del ${basename(x)}.b64"
  ]
)}
${local.registration_install_cmd_win} "C:\Users\Administrator\tableau\registration.json"
dism.exe /online /import-defaultappassociations:defaultapps.xml
echo "" > __BOOTSTRAP_COMPLETE_
echo "" > __USERDATA_SCRIPT_STARTED_
${file("${path.module}/resources/win/userdata_win.bat")}
cd C:\Users\Administrator\tableau
echo "" > _USERDATA_SCRIPT_COMPLETE_
</script>
<persist>true</persist>
EOF
}

resource "aws_key_pair" "mykey" {
  key_name   = "${var.name_prefix}ec2-keypair"
  public_key = file(local.ssh_public_key_filepath)
}

resource "aws_instance" "ec2_instance" {
  count                   = var.num_linux_instances
  ami                     = data.aws_ami.ec2_ami.id
  instance_type           = var.ec2_instance_type
  key_name                = aws_key_pair.mykey.key_name
  subnet_id               = var.subnet_ids[0]
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
    volume_size = var.ec2_instance_storage_gb
    encrypted   = true
  }
  lifecycle {
    create_before_destroy = true
    ignore_changes        = [tags]
  }
}
