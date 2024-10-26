## k8s infra init

### k8s metrics server

```bash
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
```

### karpenter (for node auto scaling)

```bash
# edit configmap
kubectl edit configmap aws-auth -n kube-system
```

```yaml
# Add section in aws-auth configmap
- groups:
  - system:bootstrappers
  - system:nodes
  rolearn: arn:${AWS_PARTITION}:iam::${AWS_ACCOUNT_ID}:role/KarpenterNodeRole-${CLUSTER_NAME}
  username: system:node:{{EC2PrivateDNSName}}
```

```bash
# install karpenter
helm upgrade --install karpenter ./karpenter -n kube-system
```

### istio

```bash
# install istio base
helm upgrade --install istio-base istio/base -n istio-system --create-namespace

# Install or upgrade the Kubernetes Gateway API CRDs
kubectl get crd gateways.gateway.networking.k8s.io &> /dev/null || \
  { kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.1.0/standard-install.yaml; }

# install istiod control plane
helm upgrade --install istiod istio/istiod --namespace istio-system --set profile=ambient
```

### prometheus & grafana

```bash
helm upgrade --install prometheus -f ./kube-prometheus-stack/values.yaml ./kube-prometheus-stack -n observability --create-namespace
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
