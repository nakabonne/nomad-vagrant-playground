name = "${NODE_NAME}"
data_dir = "/opt/nomad"
datacenter = "dc-${NODE_NAME}"

bind_addr = "{{ GetInterfaceIP \"eth1\" }}"

advertise {
  http = "{{ GetInterfaceIP \"eth1\" }}"
  rpc = "{{ GetInterfaceIP \"eth1\" }}"
  serf = "{{ GetInterfaceIP \"eth1\" }}"
}
log_file = "/var/log/nomad.log"

client {
  enabled = true
  network_interface = "eth1"
  node_class = "${NODE_NAME}"
  gc_interval = "24h"
}

consul {
  address = "127.0.0.1:8500"
}

telemetry {
  prometheus_metrics = true
}

plugin "docker" {
  config {
    volumes {
      enabled = true
    }
  }
}

vault {
  enabled = true
  address = "http://${SERVER_IP_ADDRESS}:8200/"
}
