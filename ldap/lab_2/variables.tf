variable project {
    default = "main-tokenizer-287910"
}
variable region {
    default = "us-central1"
}
variable zone {
    default = "us-central1-c"
}
variable name {
    default = "kkarpau"
}
variable machine_type {
    default = "f1-micro"
}
variable image {
    default = "centos-cloud/centos-7"
}
variable ssh_username {
    default = "centos"
}
variable ssh_key {
    default = "~/.ssh/id_rsa.pub"
}
variable ip_cidr_range {
    default = "10.6.1.0/24"
}
variable firewall_ports {
    type = list
    default = ["80", "22"]
}
variable firewall_source_ranges {
    type = list
    default = ["0.0.0.0/0"]
}
variable firewall_ports_int_tcp {
    type = list
    default = ["0-65535"]
}
variable firewall_ports_int_udp {
    type = list
    default = ["0-65535"]
}
variable firewall_source_ranges_int {
    type = list
    default = ["10.6.1.0/24"]
}
# variable compute_address {
#     default = "10.6.1.2"
# }
variable compute_address_type {
    default = "INTERNAL"
}