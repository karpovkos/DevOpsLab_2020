provider "google" {
  project       = var.project
  region        = var.region
}

#--- create network
resource "google_compute_network" "vpc_net" {
  name          = "${var.name}-vpc"
  auto_create_subnetworks = false
}

#--- create sub network
resource "google_compute_subnetwork" "vpc_subnet_public" {
  name          = "${var.name}-vpc-subnet-public"
  ip_cidr_range = var.ip_cidr_range
  region        = var.region
  network       = google_compute_network.vpc_net.id
}

#--- create firewall rule extrenal
resource "google_compute_firewall" "external-firewall" {
  name          = "${var.name}-external-rule"
  network       = google_compute_network.vpc_net.name
  allow {
    protocol    = "tcp"
    ports       = var.firewall_ports
  }
  source_ranges = var.firewall_source_ranges
}

#--- create firewall rule internal
resource "google_compute_firewall" "internal-firewall" {
  name          = "${var.name}-internal-rule"
  network       = google_compute_network.vpc_net.name
  allow {
    protocol    = "tcp"
    ports       = var.firewall_ports_int_tcp
  }
  allow {
    protocol    = "udp"
    ports       = var.firewall_ports_int_udp
  }
  allow {
    protocol    = "icmp"
  }
  source_ranges = var.firewall_source_ranges_int
}

#--- create resoure IP address 4 server 
resource "google_compute_address" "datadog_server_address" {
  name          = "${var.name}-datadog-server-address"
  subnetwork    = google_compute_subnetwork.vpc_subnet_public.id
  address_type  = var.compute_address_type
  region        = var.region
}


#--- create Datadog server instance
resource "google_compute_instance" "datadog_instance" {
  name          = "${var.name}-datadog-server-instance"
  zone          = var.zone
  machine_type  = var.machine_type
  boot_disk {
    initialize_params {
      image     = var.image
    }
  }
  metadata      = {
    ssh-keys    = "${var.ssh_username}:${file(var.ssh_key)}"
  }
  metadata_startup_script = templatefile("run_server.sh", {API_KEY = "${file(var.path_api_key)}"})
  network_interface {
    network     = google_compute_network.vpc_net.name
    network_ip  = google_compute_address.datadog_server_address.address
    subnetwork  = google_compute_subnetwork.vpc_subnet_public.name
    access_config {
    }
  }
}

#--- creating datadog monitor
# export DD_API_KEY=abcdefgijklmnopqrstuvwxyz
# export DD_APP_KEY=abcdefgijklmnopqrstuvwxyz0123456789

provider "datadog" {
  api_key = file(var.path_api_key)
  app_key = file(var.path_app_key)
  # api_url = "com.com"
}

resource "datadog_monitor" "dog-monitor" {
  name               = "test-dog-monitor"
  type               = "metric alert"
  message            = "Monitor triggered. Notify: petroff008@gmail.com"
  query              = "sum(last_5m):avg:datadog.agent.started{http-server} by {host}.as_count() < 1"
  depends_on         = [google_compute_instance.datadog_instance]
}