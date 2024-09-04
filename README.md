# Cilium on kind

Cilium is open source software for transparently securing the network connectivity between application services deployed using Linux container management platforms like Docker and Kubernetes.

At the foundation of Cilium is a new Linux kernel technology called eBPF, which enables the dynamic insertion of powerful security visibility and control logic within Linux itself. Because eBPF runs inside the Linux kernel, Cilium security policies can be applied and updated without any changes to the application code or container configuration.

## Pre-reqs (cluster setup etc)

```bash
kind create cluster --config=kind-config.yaml
```

## Setup

```bash
cilium version --client ## check cilum is installed

cilium install --version 1.16.1

cilium status ## check cilium is installed. The daemonsets should spin up 4 pods running cilium

kubectl get nodes -A ## nodes should be ready as now we have a CNI

```
