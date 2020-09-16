
output "Zabbix_Server" {
  value = "http://${google_compute_instance.zabbix_instance.network_interface.0.access_config.0.nat_ip}/zabbix"
}