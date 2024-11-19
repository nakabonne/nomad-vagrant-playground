data_dir = "/opt/nomad"

bind_addr = "0.0.0.0"

advertise {
  http = "${SERVER_IP_ADDRESS}"
  rpc = "${SERVER_IP_ADDRESS}"
  serf = "${SERVER_IP_ADDRESS}"
}

consul {
  address = "127.0.0.1:8500"
}

telemetry {
  prometheus_metrics = true
}

server {
  enabled = true
  bootstrap_expect = 1
}

log_file = "/var/log/nomad.log"

vault {
  enabled = true
  address = "http://${SERVER_IP_ADDRESS}:8200/"
  token   = "${VAULT_TOKEN}"
}
