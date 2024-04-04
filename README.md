# The Official Orbital Helm Chart

## Usage

[Helm](https://helm.sh) must be installed to use the charts.
Please refer to Helm's [documentation](https://helm.sh/docs/) to get started.

Once Helm is set up properly, add the repo as follows:

```shell
helm repo add orbital https://orbitalapi.github.io/helm
helm repo update
```

Search available version:

```shell
helm search repo orbital
```

## Install Orbital

```shell
helm upgrade -i orbital orbital/orbital --namespace=orbital --create-namespace
```

### Installing on local k8s cluster (kind/minikube)
If you are installing this chart on a local k8s cluster you will need to add the wellknown 
node labels to the nodes. This is because sane topologySpreadConstraints have been set by default
and these will prevent Orbital from starting as this constraint will be failing.

You can either create your local nodes with the setting or add the labels to your nodes once
they are already running.

#### With nodes already running
This command will add the necessary labels on your local nodes
```shell
kubectl label nodes <node-name> topology.kubernetes.io/zone="z1"
```

### Persistent storage
Orbital needs a postgres database to store data about the queries it runs i.e. linage etc.
For **POC use** only this chart allows the installing of a postgres database as part of a sub chart
in the cluster but the recommendation is to use a managed database solution instead.

The credentials of the database should be injected into the chart as environment variables. This can be down either
by letting the chart create the secret for you and injecting it into the `envFrom` section or using another external tool
like External Secrets or CSI drivers to create the secret outside the chart and inject them in too

#### Database credentials via a secret created by the chart
The chart has the ability to create a secret for you to store the database credentials.
The database credentials are needed for both the orbital and stream server services and so there is a new
property that allows you to set it once, create 1 secret for the credentials and have both services
use the same set of credentials. This secret will be injected into the `envFrom` section of both deployments.

```yaml
orbital:
  dbSecretConfig:
    VYNE_DB_USERNAME: orbital
    VYNE_DB_PASSWORD: changeme
```

You can then pass these in via your CI/CD pipeline when you are deploying the helm chart
```shell
helm upgrade -i orbital orbital/orbital --namespace=orbital \
--set orbital.dbSecretConfig.VYNE_DB_USERNAME=orbital \
--set orbital.dbSecretConfig.VYNE_DB_PASSWORD=changeme
```

#### Additional Secret / ConfigMap created by the chart
The chart also allows you to create an additional secret or config map with env vars. Both `config` and `secretConfig` are maps. The 
values defined here will be injected into a secret / config map created by the chart and injected into the `envFrom` part
of the deployment

```yaml
orbital:
  config:
    KEY: VALUE
    KEY2: VALUE2

  secretConfig:
    VYNE_ANALYTICS_PERSISTRESULTS: true
    VYNE_ANALYTICS_PERSISTREMOTECALLRESPONSES: true
```

Instead of having these values committed into a git repository you can inject them into your helm
command, and pull them out of a secret store as part of your CI/CD platform
```shell
helm upgrade -i orbital orbital/orbital --namespace=orbital \
--set orbital.secretConfig.VYNE_ANALYTICS_PERSISTRESULTS=true \
--set orbital.secretConfig.VYNE_ANALYTICS_PERSISTREMOTECALLRESPONSES=true
```

#### Enabling the sub chart to install local DB
Add the following YAML to your overrides file to enable the sub chart and configure it as needed. It uses the [Bitnami postgreSQL chart](https://github.com/bitnami/charts/tree/main/bitnami/postgresql)
and so all configurations for that chart are supported

```yaml
postgresql:
  enabled: true #this is false by default so set to true to install a postgres DB in same namespace as orbitals
  auth:
    username: orbital #this is the default so can be removed unless you want to change its value
    database: orbital #this is the default so can be removed unless you want to change its value
    password: orbital #this is the default so can be removed unless you want to change its value
```

## Example installation
Below is an example installation command, running Orbital on local cluster with local postgreSQL database
***NOTE:*** The assumption is you need to have added the node labels before this will work
```shell
helm upgrade -i orbital orbital/orbital --namespace=orbital \
--set postgresql.enabled=true \
--set orbital.dbSecretConfig.VYNE_DB_USERNAME=orbital \
--set orbital.dbSecretConfig.VYNE_DB_PASSWORD=orbital \
--set orbital.dbSecretConfig.VYNE_DB_HOST=orbital-postgresql.orbital.svc.cluster.local \
--create-namespace
```

## Port forward the UI
```shell
kubectl port-forward svc/orbital 9022:9022 -n orbital
```

## Contributing

We'd love to have you contribute! Please refer to our [contribution guidelines](CONTRIBUTING.md) for details.

## License

[Apache 2.0 License](./LICENSE).
