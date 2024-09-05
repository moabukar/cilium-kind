# Ingress controller on Kind

## Setup

```bash

make up

kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=90s


# should output "foo-app"
curl localhost/foo/hostname
# should output "bar-app"
curl localhost/bar/hostname
```
