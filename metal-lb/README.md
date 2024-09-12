# MetalLB setup on Kind

## Setup

```bash

make up

kgp -A ## verify cluster and resources are ready

kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.14.8/config/manifests/metallb-native.yaml

kubectl delete -f https://raw.githubusercontent.com/metallb/metallb/v0.14.8/config/manifests/metallb-native.yaml


networksetup -listnetworkserviceorder
networksetup -listallnetworkservices
networksetup -listallhardwareports
networksetup -getcomputername

# network stuff for metalLB
docker network inspect -f '{{.IPAM.Config}}' kind

docker network inspect kind | jq -r '.[].IPAM.Config[].Subnet | select(contains(":") | not)'

k apply -f layer-metal.yml

# test apps

k create deploy nginx --image=nginx
k expose deploy nginx --port=80 --type LoadBalancer


k create deploy nginx2 --image=nginx
k expose deploy nginx2 --port=80 --type LoadBalancer

# clean up
k delete deploy nginx nginx2
k delete svc nginx nginx2


## debugging
sudo route -n add 172.18.255.0/24 172.18.0.1
sudo route -n delete 172.18.255.0/24 # to remove

```

## mac workaround

```bash

## need this first, why?

## L3 connectivity: Connect to Docker containers from macOS host (without port binding).

brew install chipmk/tap/docker-mac-net-connect
sudo brew services start chipmk/tap/docker-mac-net-connect

sudo brew services list
sudo brew services info docker-mac-net-connect


netstat -rnf inet | grep 10.33.33.1

netstat -rnf inet | grep utun4
```
