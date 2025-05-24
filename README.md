## k8s infra init

### karpenter (For node auto scaling)

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

### istio (For service mesh)

```bash
# Insall istio using helmfile
helmfile apply -f ./istio/helmfile.yaml

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
helmfile apply -f ./argo/helmfile.yaml
```

### crossplane

```bash
helm upgrade --install crossplane ./crossplane -n crossplane-system --create-namespace
helm upgrade --install crossplane-provider
```
