## k8s infra init

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
# Add karpenter crd
helm upgrade --install karpenter-crd ./karpenter/karpenter-crd -n kube-system
# install karpenter
helm upgrade --install karpenter ./karpenter/karpenter -f ./karpenter/karpenter/overwrite-values.yaml -n kube-system
# Register karpenter node
helm upgrade --install karpenter-node ./karpenter/node -n kube-system
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
helm upgrade --install istiod ./istio/istiod -f ./istio/istiod/overwrite-values.yaml -n istio-system

## install cni node agent
helm upgrade --install istio-cni ./istio/cni -f ./istio/cni/overwrite-values.yaml -n istio-system

# Install data plane
## install ztunnel daemonset
helm upgrade --install ztunnel ./istio/ztunnel -f ./istio/ztunnel/overwrite-values.yaml -n istio-system

## install istio ingress gateway
helm upgrade --install istio-ingress ./istio/gateway -n istio-ingress --create-namespace --set profile=ambient

# Install istio observability
## install istio prometheus
kubectl apply -f ./istio/prometheus.yaml

## install kiali
helm upgrade --install kiali-operator ./istio/kiali-operator -f ./istio/kiali-operator/overwrite-values.yaml -n kiali-operator --create-namespace

## install kiali gateway
helm upgrade --install kiali-gateway ./istio/kiali-gateway -n istio-system --create-namespace

## Register istio network(ambient mode and range for namespace)
kubectl label namespace {namespace} istio.io/dataplane-mode=ambient
```

### external-dns
```bash
helm upgrade --install external-dns ./external-dns -f ./external-dns/overwrite-values.yaml -n external-dns --create-namespace
```

### argo cd

```bash
# argo cd
helm upgrade --install argocd ./argo/argo-cd -f ./argo/argo-cd/overwrite-values.yaml -n argo --create-namespace

# argocd image updater
helm upgrade --install argocd-image-updater ./argo/argocd-image-updater -f ./argo/argocd-image-updater/overwrite-values.yaml -n argo

# argo rollouts
helm upgrade --install argo-rollouts ./argo/argo-rollouts -f ./argo/argo-rollouts/overwrite-values.yaml -n argo
```

### crossplane

```bash
helm upgrade --install crossplane ./crossplane -n crossplane-system --create-namespace
helm upgrade --install crossplane-provider
```
