# Install a Kubernetes Cluster (k3s) 

Install [k3s](https://k3s.io/), a small and lightweight Kubernetes distribution:

```bash
curl -sfL https://get.k3s.io
```

# Install Helm

Install [helm](https://helm.sh/), a Kubernetes package manager:

```bash
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
rm -f get_helm.sh
```

# Install OpenFaaS 

Install [OpenFaaS](https://www.openfaas.com/), a framework for running serverless functions:

```bash
k3s kubectl apply -f https://raw.githubusercontent.com/openfaas/faas-netes/master/namespaces.yml
helm repo add openfaas https://openfaas.github.io/faas-netes/ --kubeconfig=/etc/rancher/k3s/k3s.yaml 
helm repo update --kubeconfig=/etc/rancher/k3s/k3s.yaml
helm upgrade --kubeconfig=/etc/rancher/k3s/k3s.yaml openfaas --install openfaas/openfaas --namespace openfaas --set functionNamespace=openfaas-fn --set generateBasicAuth=true
```

Retrieve OpenFaaS password (needed below, but also when the UI is used: http://NODE_IP:NODE_PORT/ui/):
```bash
PASSWORD=$(sudo k3s kubectl -n openfaas get secret basic-auth -o jsonpath="{.data.basic-auth-password}" | base64 --decode) && \
echo "OpenFaaS admin password: $PASSWORD"
```

## Install OpenFaaS CLI

Install the OpenFaaS CLI:
```bash
curl -sSL https://cli.openfaas.com | sudo sh
```

Authenticate with OpenFaaS:
```bash
# The NODE_IP can be found by running: sudo k3s kubectl decribe service/kubernetes
# The OPENFAAS_EXTERNAL_GATEWAY_PORT can be found by running: k3s kubectl get services --namespace openfaas
faas-cli login -u admin --password $PASSWORD --gateway http://<NODE_IP>:<OPENFAAS_EXTERNAL_GATEWAY_PORT>
```

Deploy the "nodeinfo" test function:
```bash
faas-cli deploy --image NodeInfo --name nodeinfo --gateway http://<NODE_IP>:<OPENFAAS_EXTERNAL_GATEWAY_PORT>
```

This "nodeinfo" function can be reached on the internal address: http://gateway.openfaas:8080 (`https://<service name>.<namespace>:<default port>`) or 
through the public interface at `http://localhost:31112/ui` using username `admin` and the previously defined password contained in environment variable `$PASSWORD`.