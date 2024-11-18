UNAME := $(shell uname)

.PHONY: vagrant-up
vagrant-up:
	@echo Starting all VMs in parallel...
	grep config.vm.define Vagrantfile | awk -F'"' '{print $$2}' | xargs -P4 -I {} vagrant up {}

.PHONY: vagrant-down
vagrant-down:
# Retry if SSH connection is interrupted
# from laptop to Linux machine during removal
	until vagrant destroy -f; do sleep 2; done

./bin/nomad:
	@mkdir -p bin
ifeq ($(UNAME), Linux)
	cd bin && curl -o nomad.zip https://releases.hashicorp.com/nomad/1.6.5/nomad_1.6.5_linux_amd64.zip && unzip nomad.zip && rm nomad.zip
	@chmod +x ./bin/nomad
else ifeq ($(UNAME), Darwin)
	cd bin && curl -o nomad.zip https://releases.hashicorp.com/nomad/1.6.5/nomad_1.6.5_darwin_amd64.zip && unzip nomad.zip && rm nomad.zip
	@chmod +x ./bin/nomad
else
	@echo "Unsupported OS, please copy your local nomad binary manually to ./bin/nomad"
	@exit 1
endif