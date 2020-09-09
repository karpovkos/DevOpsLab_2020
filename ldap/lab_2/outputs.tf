output "URL_Ldap_server" {
  value = "http://${google_compute_instance.ldap_server_instance.network_interface[0].access_config[0].nat_ip}/ldapadmin"
}
output "Ldap_client_access" {
  value = "ssh my_user@${google_compute_instance.ldap_client_instance.network_interface[0].access_config[0].nat_ip}"
}