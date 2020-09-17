output "Datadog" {
  value = google_compute_instance.datadog_instance.network_interface.0.access_config.0.nat_ip
}
