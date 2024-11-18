# -*- mode: ruby -*-
# vi: set ft=ruby :
SERVER_IP_ADDRESS       = "192.168.60.2"
CLIENT_ALPHA_IP_ADDRESS = "192.168.60.3"
CLIENT_BETA_IP_ADDRESS  = "192.168.60.4"

$set_environment_variables = <<SCRIPT
tee "/etc/profile.d/shared_vars.sh" > "/dev/null" <<EOF
export SERVER_IP_ADDRESS="192.168.60.2"
export VAULT_TOKEN="mylocalsupersecuretoken"
export VAULT_VERSION="1.9.3"
EOF
SCRIPT

Vagrant.configure("2") do |config|
  config.vm.box = "bento/ubuntu-20.04"

  config.vm.boot_timeout = 600

  config.vm.provider "virtualbox" do |v|
    v.memory = 2048
    # This is how many CPUs the VM has access to, not how many it has an exclusive
    # lock over.  This means we are oversubscribed on any dev PC but that's fine,
    # because we only will run into high CPU usage during builds.  If we get into
    # a huge CPU loop on a VM we'll still have 2 cores free to get out of trouble.
    v.cpus = 6
  end

  config.vm.provision "shell", inline: $set_environment_variables, run: "always"

  # This is the main host where we run server (Nomad, Consul, Weave)
  config.vm.define "server", primary: true do |server|
    server.vm.hostname = "server"
    server.vm.network "private_network", ip: SERVER_IP_ADDRESS
    server.vm.network :forwarded_port, guest: 8500, host: 8500, host_ip: "0.0.0.0", id: "consul", auto_correct: true
    server.vm.network :forwarded_port, guest: 4646, host: 4646, host_ip: "0.0.0.0", id: "nomad", auto_correct: true
    server.vm.network :forwarded_port, guest: 8200, host: 8200, host_ip: "0.0.0.0", id: "vault", auto_correct: true
    server.vm.synced_folder "server", "/home/vagrant/server"
    server.vm.provision "shell",
      path: "server/bootstrap.sh",
      env: {
        "NOMAD_VERSION" => "1.6.5",
      }
  end

  # These are agent servers that run things that connect to the server.
  config.vm.define "alpha" do |alpha|
    alpha.vm.provider "virtualbox" do |v|
      v.memory = 8192
    end
    alpha.vm.hostname = "alpha"
    alpha.vm.network "private_network", ip: CLIENT_ALPHA_IP_ADDRESS
    alpha.vm.synced_folder "client", "/home/vagrant/client"
    alpha.vm.provision "shell",
      path: "client/bootstrap.sh",
      env: {
        "NODE_NAME" => "alpha",
        "NOMAD_VERSION" => "1.6.5",
      }
  end
  config.vm.define "beta" do |beta|
    beta.vm.provider "virtualbox" do |v|
      v.memory = 4096
    end
    beta.vm.hostname = "beta"
    beta.vm.network "private_network", ip: CLIENT_BETA_IP_ADDRESS
    beta.vm.synced_folder "client", "/home/vagrant/client"
    beta.vm.provision "shell",
      path: "client/bootstrap.sh",
      env: {
        "NODE_NAME" => "beta",
        "NOMAD_VERSION" => "1.6.5",
      }
  end

end
