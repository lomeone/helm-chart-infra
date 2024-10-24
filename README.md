## k8s infra init

### k8s metrics server

```bash
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
```

### karpenter (for node auto scaling)

```
helm upgrade --install karpenter -f ./karpenter/values.yaml ./karpenter -n kube-system
```

### istio

```bash

```

### prometheus & grafana

```bash
helm upgrade --install prometheus prometheus-community/kube-prometheus-stack -n observability --create-namespace
```

### github action runner

```bash
# arc controller
NAMESPACE="arc-systems"
helm install arc \
    --namespace "${NAMESPACE}" \
    --create-namespace \
    oci://ghcr.io/actions/actions-runner-controller-charts/gha-runner-scale-set-controller

# Add secret
kubectl create secret generic pre-defined-secret \
   --namespace=arc-runners \
   --from-literal=github_app_id={github_app id} \  # -> github app 설정에서 확인 가능
   --from-literal=github_app_installation_id={github_app installation id} \ # -> organization에 github app 설치하면 url에서 확인 가능
   --from-file=github_app_private_key=private-key-file.pem

# Add runner scale set(Github action runner group)
INSTALLATION_NAME="arc-runner-set"
NAMESPACE="arc-runners"
GITHUB_CONFIG_URL="https://github.com/<your_enterprise/org/repo>"
GITHUB_PEM_SECRET="pre-defined-secret"
helm install "${INSTALLATION_NAME}" \
    --namespace "${NAMESPACE}" \
    --create-namespace \
    --set githubConfigUrl="${GITHUB_CONFIG_URL}" \
    --set githubConfigSecret="${GITHUB_PEM_SECRET}" \
    oci://ghcr.io/actions/actions-runner-controller-charts/gha-runner-scale-set
```

### argo cd

```

```

### crossplane

```

```
