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
helm upgrade --install karpenter ./karpenter/karpenter -n kube-system
helm upgrade --install karpenter-node ./karpenter/node -n kube-system
```

### opentelemetry collector

```bash
helm upgrade --install otel-collector ./observability/opentelemetry-collector -n observability --create-namespace
```

### istio

```bash
# Install control plane
## install istio base
helm upgrade --install istio-base ./istio/base -n istio-system --create-namespace

## install or upgrade the Kubernetes Gateway API CRDs
kubectl get crd gateways.gateway.networking.k8s.io &> /dev/null || \
  { kubectl apply -f ./istio/standard-install.yaml; }

## install istiod control plane
helm upgrade --install istiod ./istio/istiod -n istio-system

## install cni node agent
helm upgrade --install istio-cni ./istio/cni -n istio-system

# Install data plane
## install ztunnel daemonset
helm upgrade --install ztunnel ./istio/ztunnel -n istio-system

## install istio ingress gateway
helm upgrade --install istio-ingress ./istio/gateway -n istio-ingress --create-namespace --set profile=ambient

# Install istio observability
## install istio prometheus
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.24/samples/addons/prometheus.yaml

## install kiali
helm upgrade --install kiali-operator ./istio/kiali-operator -n kiali-operator --create-namespace

```

### external-dns
```bash
helm upgarde --install external-dns ./external-dns -n external-dns --create-namespace
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

```bash

```

### crossplane

```bash
helm upgrade --install crossplane ./crossplane -n crossplane-system --create-namespace
helm upgrade --install crossplane-provider
```
