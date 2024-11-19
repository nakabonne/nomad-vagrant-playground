data_dir   = "/opt/consul"
log_level  = "INFO"
retry_join = ["${SERVER_IP_ADDRESS}"]

addresses = {
  http = "127.0.0.1 {{ GetInterfaceIP \"eth1\" }}"
}

bind_addr = "{{ GetInterfaceIP \"eth1\" }}"

telemetry {
  prometheus_retention_time = "10m"
}

service {
  name = "consul-agent"
  port = 8500
  tags = ["http"]
}
