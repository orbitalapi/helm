# Orbital Helm Repository

## Add the Orbital Helm repository

```sh
helm repo add orbital https://orbitalapi.github.io/helm
helm repo update
```

## Search available version:

```bash
helm search repo orbital
```

## Install Orbital

- For helm 3.X

```bash
helm upgrade -i orbital orbital/orbital --namespace=orbital --create-namespace
```

## Port forward the UI
```bash
kubectl port-forward svc/orbital 9022:9022 -n orbital
```
