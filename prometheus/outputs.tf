
output "Prometheus_Grafana_Server" {
  value = "http://${google_compute_instance.prometheus_instance.network_interface.0.access_config.0.nat_ip}:3000"
}