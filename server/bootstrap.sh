#!/bin/bash
set -e

# ENV Vars
BASE_PATH="/home/vagrant/server"
source /etc/profile.d/shared_vars.sh

sudo apt-get update && sudo apt-get install -y unzip

# Install and Run Consul
curl -L "https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_amd64.zip" --fail --show-error -o /tmp/consul.zip
unzip /tmp/consul.zip -d /tmp/ && mv /tmp/consul /usr/local/bin/
rm /tmp/consul.zip

mkdir -p /etc/consul/services /opt/consul
cp "${BASE_PATH}/consul/consul.service" "/etc/systemd/system/consul.service"
envsubst < "${BASE_PATH}/consul/server.hcl" > /etc/consul/server.hcl
#cp -r "${BASE_PATH}/consul/services/" "/etc/consul/"

systemctl enable consul
systemctl start consul

# Install and Run Vault
curl -L "https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_amd64.zip" --fail --show-error -o /tmp/vault.zip
unzip /tmp/vault.zip -d /tmp/ && mv /tmp/vault /usr/local/bin/
rm /tmp/vault.zip

mkdir -p /etc/vault
envsubst < "${BASE_PATH}/vault/vault.service" > "/etc/systemd/system/vault.service"
envsubst < "${BASE_PATH}/vault/vault.hcl" > /etc/vault/vault.hcl

systemctl enable vault
systemctl start vault && sleep 3

# Configure Vault Secret Engine
export VAULT_ADDR="http://${SERVER_IP_ADDRESS}:8200"

echo "Vault configuration completed"

# Install and Run Nomad
curl -L "https://releases.hashicorp.com/nomad/${NOMAD_VERSION}/nomad_${NOMAD_VERSION}_linux_amd64.zip" --fail --show-error -o /tmp/nomad.zip
unzip /tmp/nomad.zip -d /tmp/ && mv /tmp/nomad /usr/local/bin/
rm /tmp/nomad.zip

mkdir -p /etc/nomad /opt/nomad
cp "${BASE_PATH}/nomad/nomad.service" "/etc/systemd/system/nomad.service"
envsubst < "${BASE_PATH}/nomad/server.hcl" > /etc/nomad/server.hcl

systemctl enable nomad
systemctl start nomad

# Wait for Nomad to come up
attempts=0
while ! nomad status; do
  attempts=$((attempts+1))
  if [[ "$attempts" -gt 5 ]]; then
    echo "ERROR: Nomad still not available"
    exit 1
  fi
  sleep 1
done

# Start all Nomad jobs
# nomadjobs="${BASE_PATH}/nomadjobs/*.nomad"
# for job in ${nomadjobs}; do
#   nomad run "${job}"
# done
