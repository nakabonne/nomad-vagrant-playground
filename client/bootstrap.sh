#!/bin/bash
set -e

BASE_PATH="/home/vagrant/client"
source /etc/profile.d/shared_vars.sh

# Configure iptables
cat <<'EOF' | sudo tee /etc/modules-load.d/iptables.conf
iptable_nat
iptable_mangle
iptable_raw
iptable_filter
ip6table_mangle
ip6table_raw
ip6table_filter
EOF

# Install docker
sudo apt-get update
sudo apt-get install -y ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
# Verify the installation is successful
sudo docker run hello-world

# Configure docker daemon so its default IP range doesn't conflict with Cilium's one
cp "${BASE_PATH}/docker/daemon.json" "/etc/docker/daemon.json "
sudo systemctl restart docker

mkdir -p /tmp
mkdir -p /opt/cni/bin
sudo docker run --rm --entrypoint bash -v /tmp:/out cilium/cilium:v1.13.2 -c \
  'cp /usr/bin/cilium* /out; cp /opt/cni/bin/cilium-cni /out'
sudo mv /tmp/cilium-cni /opt/cni/bin/cilium-cni
sudo mv /tmp/cilium* /usr/local/bin

# Run Cilium agent
mkdir -p /opt/cni/conf.d
cp "${BASE_PATH}/cilium/cilium.service" "/etc/systemd/system/cilium.service"
cp "${BASE_PATH}/cilium/cilium.conflist" "/opt/cni/conf.d/cilium.conflist"
systemctl enable cilium
systemctl start cilium

echo Cilium started

sudo apt-get update && sudo apt-get install -y unzip

# Install and Run Consul
curl -L "https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_amd64.zip" --fail --show-error -o /tmp/consul.zip
unzip /tmp/consul.zip -d /tmp/ && mv /tmp/consul /usr/local/bin/
rm /tmp/consul.zip

mkdir -p /etc/consul /opt/consul
cp "${BASE_PATH}/consul/consul.service" "/etc/systemd/system/consul.service"
envsubst < "${BASE_PATH}/consul/client.hcl" > /etc/consul/client.hcl

systemctl enable consul
systemctl start consul

# Install and Run Nomad
curl -L "https://releases.hashicorp.com/nomad/${NOMAD_VERSION}/nomad_${NOMAD_VERSION}_linux_amd64.zip" --fail --show-error -o /tmp/nomad.zip
unzip /tmp/nomad.zip -d /tmp/ && mv /tmp/nomad /usr/local/bin/
rm /tmp/nomad.zip

mkdir -p /etc/nomad /opt/nomad /opt/nomad/plugins
cp "${BASE_PATH}/nomad/nomad.service" "/etc/systemd/system/nomad.service"
envsubst < "${BASE_PATH}/nomad/client.hcl" > /etc/nomad/client.hcl

systemctl enable nomad
systemctl start nomad

echo Nomad started
