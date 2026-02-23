# Kubernetes Manifests

## Baseline Objects per Service

- `Deployment`
- `Service` (ClusterIP)
- `HorizontalPodAutoscaler`
- `PodDisruptionBudget`
- `ConfigMap`
- `Secret` reference
- Optional `ServiceMonitor` for Prometheus scraping

## Deployment Template (Excerpt)

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: order-service
  namespace: zimbite-core
spec:
  replicas: 3
  selector:
    matchLabels:
      app: order-service
  template:
    metadata:
      labels:
        app: order-service
    spec:
      containers:
        - name: app
          image: ghcr.io/zimbite/order-service:{{TAG}}
          ports:
            - containerPort: 8086
          envFrom:
            - configMapRef:
                name: order-service-config
            - secretRef:
                name: order-service-secrets
          resources:
            requests:
              cpu: "250m"
              memory: "512Mi"
            limits:
              cpu: "1000m"
              memory: "1Gi"
```

## Ingress Rules

- Single host with path routing to gateway.
- TLS certificate via cert-manager.
- WAF and IP throttling at ingress edge.
