#!/bin/bash
set -e

BASE_PATH="/home/vagrant/client"
source /etc/profile.d/shared_vars.sh

sudo apt-get update && sudo apt-get install -y unzip

# Install and Run Consul
# mkdir -p /etc/consul /opt/consul
# cp "${BASE_PATH}/consul/consul.service" "/etc/systemd/system/consul.service"
# envsubst < "${BASE_PATH}/consul/client.hcl" > /etc/consul/client.hcl

# systemctl enable consul
# systemctl start consul

# Install and Run Nomad
curl -L "https://releases.hashicorp.com/nomad/${NOMAD_VERSION}/nomad_${NOMAD_VERSION}_linux_amd64.zip" --fail --show-error -o /tmp/nomad.zip
unzip /tmp/nomad.zip -d /tmp/ && mv /tmp/nomad /usr/local/bin/
rm /tmp/nomad.zip

mkdir -p /etc/nomad /opt/nomad /opt/nomad/plugins
cp "${BASE_PATH}/nomad/nomad.service" "/etc/systemd/system/nomad.service"
envsubst < "${BASE_PATH}/nomad/client.hcl" > /etc/nomad/client.hcl

systemctl enable nomad
systemctl start nomad
