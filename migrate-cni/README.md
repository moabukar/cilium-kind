# Cilium migration from another CNI (advanced)

Migrating from one CNI to another. In this case, migrating from Flannel to Cilium. Could also be from AWS CNI or another CNI to Cilium for example.

## Setup

```bash
kind create cluster --config=kind-config.yaml


kubectl apply -n kube-system --server-side -f https://raw.githubusercontent.com/cilium/cilium/1.16.1/examples/misc/migration/install-reference-cni-plugins.yaml

kubectl apply --server-side -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml

kubectl wait --for=condition=Ready nodes --all

```


## Cilium install & prep

```bash

## Select a new CIDR for pods. It must be distinct from all other CIDRs in use. For Kind clusters, the default is 10.244.0.0/16. So, for this example, we will use 10.245.0.0/16.

> nodeips
NODE                 POD_CIDR
kind-control-plane   10.244.0.0/24
kind-worker          10.244.3.0/24
kind-worker2         10.244.2.0/24
kind-worker3         10.244.1.0/24

^^ Cluster CIDR: 10.244.0.0/22

#########

## Install Cilium on same cluster

cilium install --version 1.16.1 --values values-migration.yaml --dry-run-helm-values > values-initial.yaml


helm repo add cilium https://helm.cilium.io/

helm install cilium cilium/cilium --namespace kube-system --values values-initial.yaml

cilium status --wait
```

## Migration

```bash

NODE="kind-worker" # for the Kind example

kubectl cordon $NODE
kubectl drain --ignore-daemonsets $NODE

kubectl label node $NODE --overwrite "io.cilium.migration/cilium-default=true"

kubectl -n kube-system delete pod --field-selector spec.nodeName=$NODE -l k8s-app=cilium
kubectl -n kube-system rollout status ds/cilium -w

# if using Docker
docker restart $NODE

cilium status --wait
kubectl get -o wide node $NODE
kubectl -n kube-system run --attach --rm --restart=Never verify-network \
  --overrides='{"spec": {"nodeName": "'$NODE'", "tolerations": [{"operator": "Exists"}]}}' \
  --image ghcr.io/nicolaka/netshoot:v0.8 -- /bin/bash -c 'ip -br addr && curl -s -k https://$KUBERNETES_SERVICE_HOST/healthz && echo'

kubectl uncordon $NODE
```


## Post migration

```bash

cilium status

cilium install --version 1.16.1 --values values-initial.yaml --dry-run-helm-values   --set operator.unmanagedPodWatcher.restart=true --set cni.customConf=false   --set policyEnforcementMode=default   --set bpf.hostLegacyRouting=false > values-final.yaml

diff values-initial.yaml values-final.yaml

# Then, apply the changes to the cluster:

helm upgrade --namespace kube-system cilium cilium/cilium --values values-final.yaml

kubectl -n kube-system rollout restart daemonset cilium

cilium status --wait

kubectl delete -n kube-system ciliumnodeconfig cilium-default

#####

# Delete the previous network plugin.

# At this point, all pods should be using Cilium for networking. You can easily verify this with `cilium status`. It is now safe to delete the previous network plugin from the cluster.

# Most network plugins leave behind some resources, e.g. iptables rules and interfaces. These will be cleaned up when the node next reboots. If desired, you may perform a rolling reboot again.
```
