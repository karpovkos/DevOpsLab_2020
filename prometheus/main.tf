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

#--- create firewall rule extrenal grafana
resource "google_compute_firewall" "external-firewall-grafana" {
  name          = "${var.name}-external-rule-grafana"
  network       = google_compute_network.vpc_net.name
  allow {
    protocol    = "tcp"
    ports       = var.firewall_ports_grafana
  }
  source_ranges = var.firewall_grafana_source_ranges
  target_tags    = ["grafana"]
}

#--- create firewall rule extrenal node
resource "google_compute_firewall" "external-firewall-node" {
  name          = "${var.name}-external-rule-node"
  network       = google_compute_network.vpc_net.name
  allow {
    protocol    = "tcp"
    ports       = var.firewall_ports_node
  }
  source_ranges = var.firewall_node_source_ranges
  target_tags    = ["node"]

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

#--- create resoure IP address for server 
resource "google_compute_address" "prometheus_server_address" {
  name          = "${var.name}-prometheus-server-address"
  subnetwork    = google_compute_subnetwork.vpc_subnet_public.id
  address_type  = var.compute_address_type
  region        = var.region
}

#--- create resoure IP address for client
resource "google_compute_address" "node_server_address" {
  name          = "${var.name}-node-server-address"
  subnetwork    = google_compute_subnetwork.vpc_subnet_public.id
  address_type  = var.compute_address_type
  region        = var.region
}


#--- create Prometheus Grafana server instance
resource "google_compute_instance" "prometheus_instance" {
  name          = "${var.name}-prometheus-server-instance"
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
  metadata_startup_script = templatefile("run_server.sh", {IP_Address = "${google_compute_address.node_server_address.address}"})
  network_interface {
    network     = google_compute_network.vpc_net.name
    network_ip  = google_compute_address.prometheus_server_address.address
    subnetwork  = google_compute_subnetwork.vpc_subnet_public.name
    access_config {
    }
  }
  depends_on    = [google_compute_address.node_server_address]
  tags          = ["http-server", "https-server","grafana"]
}

#--- create Node Exporter client instance
resource "google_compute_instance" "node_instance" {
  name          = "${var.name}-node-instance"
  zone          = var.zone
  machine_type  = var.machine_type
  boot_disk {
    initialize_params {
      image     = var.image
    }
  }
  metadata_startup_script = templatefile("run_client.sh", {name = "${var.name}"})
  network_interface {
    network     = google_compute_network.vpc_net.name
    network_ip  = google_compute_address.node_server_address.address
    subnetwork  = google_compute_subnetwork.vpc_subnet_public.name
    access_config {
    }
  }
  tags          = ["http-server", "https-server", "node"]

}