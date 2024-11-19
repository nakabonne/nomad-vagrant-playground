server = true
bootstrap_expect = 1
client_addr = "0.0.0.0"
ui_config {
  enabled = true
}

data_dir   = "/opt/consul"
log_level  = "INFO"
retry_join = ["${SERVER_IP_ADDRESS}"]

advertise_addr = "${SERVER_IP_ADDRESS}"
bind_addr = "0.0.0.0"

telemetry {
  prometheus_retention_time = "10m"
}

service {
  name = "consul-server"
  port = 8500
  tags = ["http"]
}
