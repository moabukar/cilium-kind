# Kind local

Kind setup for the purpose of using network policies. A kind cluster with 3 nodes and no default CNI (the default CNI used by kind is kindnetd) but we will use Cilium

```bash
cilium install

cilium status
```

## Test network pols

```bash
kubectl crete ns demo

k apply -f backend.yaml

k apply -f frontend.yaml

kubectl exec -n demo -it frontend-f4584dffc-q5s27 -- curl backend.demo.svc.cluster.local

## connectivity should work on above

## let's try a different pod

kubectl run -n demo test-pod --image=busybox --restart=Never -- sleep 3600

# if you want to spin up a throw away pod for debugging.
kubectl run tmp-shell --rm -i --tty --image moabukar/netshoot

curl backend.demo.svc.cluster.local ## shouldn't work

```
