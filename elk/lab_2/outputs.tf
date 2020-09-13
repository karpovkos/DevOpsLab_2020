
output "Elastic_Kibana" {
  value = "http://${google_compute_instance.elastic_kibana_instance.network_interface.0.access_config.0.nat_ip}:5601"
}

output "Tomcat_Logstash" {
  value = "http://${google_compute_instance.tomcat_logstash_instance.network_interface.0.access_config.0.nat_ip}:8080"
}

output "Elastic_Cluster_Health"{
  value = "http://${google_compute_instance.elastic_kibana_instance.network_interface[0].access_config[0].nat_ip}:9200/_cluster/health?pretty"
}
output "Elastic_Indices"{
  value = "http://${google_compute_instance.elastic_kibana_instance.network_interface[0].access_config[0].nat_ip}:9200/_cat/indices?v"
}
