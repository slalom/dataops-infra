/*
* The Network module creates a number of network services which support other key AWS functions.
*
* Included automatically when creating this module:
* * 1 Network which contains the following:
*     * 2 private subnets (for resources which **do not** need a public IP address)
*     * 2 public subnets (for resources which do need a public IP address)
*     * 1 NAT gateway (allows private subnet resources to reach the outside world)
*     * 1 Intenet gateway (allows resources in public and private subnets to reach the internet)
*     * route tables and routes to connect all of the above
*/

data "http" "icanhazip" { url = "http://icanhazip.com" }

locals {
  project_shortname = substr(var.name_prefix, 0, length(var.name_prefix) - 1)
  my_ip             = chomp(data.http.icanhazip.body)
  my_ip_cidr        = "${chomp(data.http.icanhazip.body)}/32"
  region            = var.region
  subnet_cidrs = coalesce(
    var.subnet_cidrs,
    cidrsubnets(var.vpc_cidr, 2, 2, 2, 2)
  )
}

//Set up Provider
provider "google" {
  credentials = var.credentials_file
  project     = var.project
  region      = var.region
//  TODO: Determine if the zone is pulled dynamically or passed as a variable
  zone        = var.zone
}

// TODO: Update this to pull zones for GCP
//Determine Zones
//data "aws_availability_zones" "az_list" {
//  provider = google.region_lookup
//}

/******************************************
	VPC
 *****************************************/
//GCP
resource "google_compute_network" "network" {
  name         = "${var.name_prefix}VPC"
  routing_mode = var.routing_mode
  project      = var.project
  description  = "${var.name_prefix} VPC"

  auto_create_subnetworks         = "false"
  delete_default_routes_on_create = "true"
}

/******************************************
	Subnets
 *****************************************/
//Public Subnets
resource "google_compute_subnetwork" "public" {
  count                    = var.disabled ? 0 : 2
  name                     = "${google_compute_network.network.name}-public-${count.index}"
  ip_cidr_range            = local.subnet_cidrs[count.index]
  region                   = var.region
  private_ip_google_access = "true"

  network     = google_compute_network.network.name
  project     = var.project
  description = "${google_compute_network.network.name} Public Subnet: ${count.index}"

  log_config {
    aggregation_interval = var.flow_logs_config.interval
    flow_sampling        = var.flow_logs_config.sampling
    metadata             = var.flow_logs_config.metadata
  }
}

//Private Subnets
resource "google_compute_subnetwork" "private" {
  count                    = var.disabled ? 0 : 2
  name                     = "${google_compute_network.network.name}-private-${count.index}"
  ip_cidr_range            = local.subnet_cidrs[count.index + 2]
  region                   = var.region
  private_ip_google_access = "true"

  network     = google_compute_network.network.name
  project     = var.project
  description = "${google_compute_network.network.name} Private Subnet: ${count.index}"

  log_config {
    aggregation_interval = var.flow_logs_config.interval
    flow_sampling        = var.flow_logs_config.sampling
    metadata             = var.flow_logs_config.metadata
  }
}

// TODO: Internet Gateway should be handled by routes


/******************************************
	NAT Gateway
 *****************************************/
//GCP
resource "google_compute_router_nat" "nat" {
  name                               = "${var.name_prefix}NAT"
  router                             = google_compute_router.router.name
  region                             = google_compute_router.router.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

//TODO: Add NAT routes


/******************************************
	Routes
 *****************************************/
resource "google_compute_router" "router" {
  name    = "${var.name_prefix}NAT"
  network = google_compute_network.network.name
//  TODO: Update bgp routes
//  bgp {
//    asn               = 64514
//    advertise_mode    = "CUSTOM"
//    advertised_groups = ["ALL_SUBNETS"]
//    advertised_ip_ranges {
//      range = "1.2.3.4"
//    }
//    advertised_ip_ranges {
//      range = "6.7.0.0/16"
//    }
  }
}

// TODO: Create Routes for GCP
//AWS routes listed here as a reference
//resource "aws_route_table" "public_rt" {
//  count  = var.disabled ? 0 : 1
//  vpc_id = aws_vpc.my_vpc[0].id
//  tags = merge(
//    var.resource_tags,
//    { Name = "${var.name_prefix}PublicRT" }
//  )
//}
//
//resource "aws_route_table_association" "public_rt_assoc" {
//  count          = var.disabled ? 0 : 2
//  route_table_id = aws_route_table.public_rt[0].id
//  subnet_id      = aws_subnet.public_subnets[count.index].id
//}
//
//resource "aws_route" "igw_route" {
//  count                  = (var.enable_internet_gateway && (var.disabled == false)) ? 1 : 0
//  route_table_id         = aws_route_table.public_rt[0].id
//  gateway_id             = aws_internet_gateway.my_igw[0].id
//  destination_cidr_block = "0.0.0.0/0"
//}
//
//resource "aws_route_table_association" "private_rt_assoc" {
//  count          = var.disabled ? 0 : 2
//  route_table_id = aws_route_table.private_rt[0].id
//  subnet_id      = aws_subnet.private_subnets[count.index].id
//}
//
//resource "aws_route_table" "private_rt" {
//  count  = var.disabled ? 0 : 1
//  vpc_id = aws_vpc.my_vpc[0].id
//  tags = merge(
//    var.resource_tags,
//    { Name = "${var.name_prefix}PrivateRT" }
//  )
//}
//
//resource "aws_route" "nat_route" {
//  count                  = var.disabled ? 0 : 1
//  route_table_id         = aws_route_table.private_rt[0].id
//  nat_gateway_id         = aws_nat_gateway.nat_gateway[0].id
//  destination_cidr_block = "0.0.0.0/0"
//}
