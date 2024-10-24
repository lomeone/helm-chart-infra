## k8s infra init

### k8s metrics server

```
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
```

### karpenter (for node auto scaling)

```
helm upgrade --install karpenter -f ./karpenter/values.yaml ./karpenter -n kube-system
```
