# Orbital Helm Chart

Add Helm repository to the repos:

```bash
helm repo add quadcorps https://charts.quadcorps.co.uk
helm repo update
```

Search available version:

```bash
helm search repo quadcorps
```

## Install Orbital

- For helm 3.X

```bash
kubectl create ns orbital
helm install orbital quadcorps/orbital --namespace=orbital --create-namespace
```
### Change namespace
If you want to change the namespace on the chart this can be done by overriding the following fields
```bash
kubectl create ns orbital
helm install orbital quadcorps/orbital --namespace=xxx --set orbital.namespace=xxx --set schema.namespace=xxx
```

## Port forward the UI
```bash
kubectl port-forward svc/orbital 9022:9022 -n orbital
```
