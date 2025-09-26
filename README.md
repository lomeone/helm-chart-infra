## k8s infra init

### Cilium (For CNI part of load balance and network policies)
```bash
helmfile apply -f ./cilium/helmfile.yaml
```

### OLM (operator lifecycle manager)

```bash
# Install operator sdk in local mac
brew install operator-sdk

# Install OLM in cluster
operator-sdk olm install
```

### Operators (operators install using olm)

```bash
# Install operators
helm upgrade --install operators ./operators -n operators
```

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
helmfile apply -f ./karpenter/helmfile.yaml
```

### istio (For service mesh)

```bash
# Install gateway api crd(Experimental Channel)
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.3.0/experimental-install.yaml

# Install istio using helmfile
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
