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
  target_tags   = ["elk", "tomcat"] 
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

#--- create EK server instance
resource "google_compute_instance" "elastic_kibana_instance" {
  name          = "${var.name}-ek-server-instance"
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
  metadata_startup_script = templatefile("run_ek.sh", {name = "${var.name}"})
  network_interface {
    network     = google_compute_network.vpc_net.name
    network_ip  = google_compute_address.ek_server_address.address
    subnetwork  = google_compute_subnetwork.vpc_subnet_public.name
    access_config {
    }
  }
  tags          = ["http-server", "elk"]
}

#--- create ldap client instance
resource "google_compute_instance" "tomcat_logstash_instance" {
  name          = "${var.name}-tomcat-logstash-instance"
  zone          = var.zone
  machine_type  = var.machine_type
  boot_disk {
    initialize_params {
      image     = var.image
    }
  }
  metadata_startup_script = templatefile("run_tomcat.sh", {server_adress = "${google_compute_address.ek_server_address.address}"})
  network_interface {
    network     = google_compute_network.vpc_net.name
    subnetwork  = google_compute_subnetwork.vpc_subnet_public.name
    access_config {
    }
  }
  tags          = ["http-server", "tomcat"]

}
resource "google_compute_address" "ek_server_address" {
  name          = "${var.name}-ek-server-address"
  subnetwork    = google_compute_subnetwork.vpc_subnet_public.id
  address_type  = var.compute_address_type
  region        = var.region
}