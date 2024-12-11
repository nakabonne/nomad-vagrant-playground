# nomad-vagrant-playground

## Prerequisite

- Install [Virtualbox](https://www.virtualbox.org/wiki/Downloads)
- Install [Vagrant](https://developer.hashicorp.com/vagrant/docs/installation)
- Install [direnv](https://direnv.net/docs/installation.html)

### Install commands

```
make ./bin/nomad
make ./bin/consul
```

## Start Nomad cluster

```
make vagrant-up
```

## Confirm Netreap is running on all nodes

```
nomad status netreap
```

## Run example jobs

```
nomad run examples/redis.nomad
```

## Apply network policy

```
consul kv put netreap.io/policy @policy.json
```

## Cleanup

```
make vagrant-down
```
