/*
* The Network module creates a number of network services which support other key AWS functions.
*
* Included automatically when creating this module:
* * 1 Network which contains the following:
*     * 2 private subnets (for resources which **do not** need a public IP address)
*     * 2 public subnets (for resources which do need a public IP address)
*     * 1 NAT router (allows private subnet resources to reach the outside world)
*     * 1 Internet Gateway Route (allows resources in public and private subnets to reach the internet)
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
  zone        = data.google_compute_zones.available.names[count.index]
}

data "google_compute_zones" "available" {}

//GCP
resource "google_compute_network" "network" {
  name         = "${var.name_prefix}VPC"
  routing_mode = var.routing_mode
  project      = var.project
  description  = "${var.name_prefix} VPC"

  auto_create_subnetworks         = "false"
  delete_default_routes_on_create = "true"
}

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

// Routes
resource "google_compute_router" "router" {
  name    = "${var.name_prefix}Router"
  region  = google_compute_subnetwork.public.region
  network = google_compute_network.network.name
  bgp {
    asn               = 64514
//    advertise_mode    = "CUSTOM"
//    advertised_groups = ["ALL_SUBNETS"]
//    advertised_ip_ranges {
//      range = "1.2.3.4"
//    }
//    advertised_ip_ranges {
//      range = "6.7.0.0/16"
  }
}

// NAT Router
resource "google_compute_router_nat" "nat" {
  name                               = "${var.name_prefix}NAT"
  router                             = google_compute_router.router.name
  region                             = google_compute_router.router.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
  udp_idle_timeout_sec               = var.udp_idle_timeout_sec
  icmp_idle_timeout_sec              = var.icmp_idle_timeout_sec
  tcp_established_idle_timeout_sec   = var.tcp_established_idle_timeout_sec
  tcp_transitory_idle_timeout_sec    = var.tcp_transitory_idle_timeout_sec

  log_config {
    enable = true
    filter = var.log_config_filter
  }
}

// Internet Routes
resource "google_compute_route" "igw_route" {
  project = var.project
  network = google_compute_network.network.name
  name                   = "${var.name_prefix}InternetEgress"
  description            = "route through IGW to access internet"
  tags                   = "egress-inet"
  dest_range             = "0.0.0.0/0"
  next_hop_internet      = "true"
  next_hop_gateway       = "default-internet-gateway"
  priority               = "100"

}
