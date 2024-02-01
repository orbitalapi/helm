# The Official Orbital Helm Chart

## Usage

[Helm](https://helm.sh) must be installed to use the charts.
Please refer to Helm's [documentation](https://helm.sh/docs/) to get started.

Once Helm is set up properly, add the repo as follows:

```bash
helm repo add orbital https://orbitalapi.github.io/helm
helm repo update
```

Search available version:

```bash
helm search repo orbital
```

## Install Orbital

```bash
helm install orbital orbital/orbital --namespace=orbital --create-namespace
```
### Change namespace
If you want to change the namespace on the chart this can be done by overriding the following fields
```bash
helm install orbital orbital/orbital --namespace=xxx --set orbital.namespace=xxx --set schema.namespace=xxx
```

## Port forward the UI
```bash
kubectl port-forward svc/orbital 9022:9022 -n orbital
```

## Contributing

We'd love to have you contribute! Please refer to our [contribution guidelines](CONTRIBUTING.md) for details.

## License

[Apache 2.0 License](./LICENSE).
