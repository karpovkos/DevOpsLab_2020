output "URL" {
  value = "http://${google_compute_instance.ldap_server_instance.network_interface[0].access_config[0].nat_ip}/ldapadmin"
}