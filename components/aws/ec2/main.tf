/*
* EC2 is the virtual machine layer of the AWS platform. This module allows you to pass your own startup scripts, and it streamlines the creation and usage of
* credentials (passwords and/or SSH keypairs) needed to connect to the instances.
*
*
*/

data "http" "icanhazip" { url = "https://ipv4.icanhazip.com" }

locals {
  project_shortname = substr(var.name_prefix, 0, length(var.name_prefix) - 1)
  my_ip             = chomp(data.http.icanhazip.body)
  my_ip_cidr        = "${chomp(data.http.icanhazip.body)}/32"
  admin_cidr        = flatten([local.my_ip_cidr, var.admin_cidr])
  app_cidr          = length(var.app_cidr) == 0 ? local.admin_cidr : var.app_cidr
  pricing_regex = chomp(
    <<EOF
${var.environment.aws_region}\\\"\\X*${replace(var.instance_type, ".", "\\.")}\\X*prices\\X*USD:\\\"(\\X*)\\\"
EOF
  )
  chocolatey_install_win = <<EOF
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command " [System.Net.ServicePointManager]::SecurityProtocol = 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))" && SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"
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
  count       = var.num_instances > 0 ? 1 : 0
  name_prefix = "${var.name_prefix}SecurityGroupForAdminPorts"
  description = "allow admin traffic from whitelisted IPs"
  vpc_id      = var.environment.vpc_id
  tags        = var.resource_tags
  dynamic "ingress" {
    for_each = var.admin_ports
    content {
      protocol    = "tcp"
      description = ingress.key
      from_port   = tonumber(split(":", ingress.value)[0])
      to_port     = length(split(":", ingress.value)) > 1 ? tonumber(split(":", ingress.value)[1]) : tonumber(ingress.value)
      cidr_blocks = local.admin_cidr
    }
  }
}

resource "aws_security_group" "ec2_sg_app_ports" {
  count       = var.num_instances > 0 ? 1 : 0
  name_prefix = "${var.name_prefix}SecurityGroupForAppPorts"
  description = "allow app traffic on whitelisted ports"
  vpc_id      = var.environment.vpc_id
  tags        = var.resource_tags
  dynamic "ingress" {
    for_each = var.app_ports
    content {
      protocol    = "tcp"
      description = ingress.key
      from_port   = tonumber(split(":", ingress.value)[0])
      to_port     = length(split(":", ingress.value)) > 1 ? tonumber(split(":", ingress.value)[1]) : tonumber(ingress.value)
      cidr_blocks = local.app_cidr
    }
  }
}

resource "aws_security_group" "ec2_sg_allow_all_outbound" {
  count       = var.num_instances > 0 ? 1 : 0
  name_prefix = "${var.name_prefix}SecurityGroupForOutbound"
  description = "allow all outbound traffic"
  vpc_id      = var.environment.vpc_id
  tags        = var.resource_tags
  egress {
    protocol    = "tcp"
    from_port   = "0"
    to_port     = "65535"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ecs_cluster_traffic" {
  count       = length(var.cluster_ports) > 0 && var.num_instances > 1 ? 1 : 0
  name_prefix = "${var.name_prefix}SecurityGroupForClustering"
  description = "allow cluster traffic between instances"
  vpc_id      = var.environment.vpc_id
  tags        = var.resource_tags
  dynamic "egress" {
    for_each = var.cluster_ports
    content {
      description = egress.key
      self        = true
      protocol    = "tcp"
      from_port   = split(":", egress.value)[0]
      to_port     = reverse(split(":", egress.value))[0]
    }
  }
  dynamic "ingress" {
    for_each = var.cluster_ports
    content {
      description = ingress.key
      self        = true
      protocol    = "tcp"
      from_port   = split(":", ingress.value)[0]
      to_port     = reverse(split(":", ingress.value))[0]
    }
  }
}

resource "aws_instance" "ec2_instances" {
  count         = var.num_instances
  ami           = data.aws_ami.ec2_ami.id
  instance_type = var.instance_type
  key_name      = var.ssh_keypair_name

  # Distribute instances into the public or private subnets using round-robin distribution.
  subnet_id = element(var.use_private_subnets ? var.environment.private_subnets : var.environment.public_subnets, count.index)

  get_password_data           = var.is_windows
  associate_public_ip_address = true
  ebs_optimized               = true
  monitoring                  = true
  disable_api_termination     = false

  user_data = var.is_windows ? replace(local.userdata_win, "<script>", "<script>\nSET EC2_NODE_INDEX=${count.index}\n") : replace(local.userdata_lin, "#!/bin/bash", "#!/bin/bash\nexport EC2_NODE_INDEX=${count.index}\n")
  tags = merge(
    var.resource_tags,
    { name = "${var.name_prefix}EC2${count.index}" }
  )
  vpc_security_group_ids = flatten([[
    aws_security_group.ec2_sg_admin_ports[0].id,
    aws_security_group.ec2_sg_allow_all_outbound[0].id,
    aws_security_group.ec2_sg_app_ports[0].id
    ], length(var.cluster_ports) == 0 || var.num_instances == 1 ? [] : [
    aws_security_group.ecs_cluster_traffic[0].id
  ]])
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
echo "" > ___BOOSTSTRAP_UNPACK_STARTED_
export PROJECT=${local.project_shortname}
${var.use_https == false ? "" : "export HTTPS_DOMAIN=${var.https_domain}"}
${join("\n",
  [for x in var.file_resources :
    substr(x, 0, 4) == "http"
    ? "curl ${split("::", x)[0]} > ${length(split("::", x)) == 1 ? basename(x) : split("::", x)[1]}"
    : "echo ${base64encode(file(split("::", x)[0]))} | base64 --decode > ${length(split("::", x)) == 1 ? basename(x) : split("::", x)[1]}"
  ]
)}
echo "" > __BOOTSTRAP_UNPACK_COMPLETE_
echo "" > _BOOTSTRAP_SCRIPT_STARTED_
sudo chmod -R 777 $HOMEDIR
./bootstrap.sh
echo "" > _BOOTSTRAP_SCRIPT_COMPLETE_
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
    ? "curl ${x} > ${length(split("::", x)) == 1 ? basename(x) : split("::", x)[1]}"
    : "echo ${base64encode(file("${x}"))} > ${basename(x)}.b64 && certutil -decode ${basename(x)}.b64 ${length(split("::", x)) == 1 ? basename(x) : split("::", x)[1]} & del ${basename(x)}.b64"
  ]
)}
dism.exe /online /import-defaultappassociations:defaultapps.xml
echo "" > __BOOTSTRAP_COMPLETE_
echo "" > __USERDATA_SCRIPT_STARTED_
bootstrap.bat
cd %HOMEDIR%
echo "" > _USERDATA_SCRIPT_COMPLETE_
</script>
<persist>true</persist>
EOF
}
