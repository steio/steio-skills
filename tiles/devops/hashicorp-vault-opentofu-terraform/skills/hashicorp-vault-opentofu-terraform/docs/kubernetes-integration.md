# Kubernetes Integration Reference

Advanced Kubernetes integration patterns for HashiCorp Vault.

## 1. Vault Agent Injector with Helm

```hcl
# kubernetes/vault-agent.tf

resource "helm_release" "vault_agent" {
  name             = "vault"
  repository       = "https://helm.releases.hashicorp.com"
  chart            = "vault"
  namespace        = "vault"
  create_namespace = true
  version          = "0.27.0"

  values = [
    yamlencode({
      injector = {
        enabled = true
        image = {
          repository = "hashicorp/vault"
          tag        = "1.15"
        }
      }

      server = {
        ha = {
          enabled  = true
          replicas = 3
        }

        dataStorage = {
          size = "10Gi"
        }

        auditStorage = {
          size = "10Gi"
        }
      }
    })
  ]

  set {
    name  = "server.dev.enabled"
    value = "false"
  }

  set {
    name  = "server.standalone.enabled"
    value = "false"
  }
}
```

## 2. External Secrets Operator Integration

```hcl
# kubernetes/external-secrets.tf

# Install ESO
resource "helm_release" "external_secrets" {
  name             = "external-secrets"
  repository       = "https://charts.external-secrets.io"
  chart            = "external-secrets"
  namespace        = "external-secrets-system"
  create_namespace = true
  version          = "0.9.11"

  set {
    name  = "installCRDs"
    value = "true"
  }
}

# ClusterSecretStore for Vault
resource "kubectl_manifest" "vault_secret_store" {
  yaml_body = <<-YAML
apiVersion: external-secrets.io/v1beta1
kind: ClusterSecretStore
metadata:
  name: vault-backend
spec:
  provider:
    vault:
      server: "https://vault.example.com:8200"
      path: "secret"
      version: "v2"
      auth:
        kubernetes:
          mountPath: "kubernetes"
          role: "eso-role"
  YAML
}

# ExternalSecret to sync Vault secrets
resource "kubectl_manifest" "app_secret" {
  yaml_body = <<-YAML
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: app-secrets
  namespace: production
spec:
  refreshInterval: 1h
  secretStoreRef:
    name: vault-backend
    kind: ClusterSecretStore
  target:
    name: app-secrets
    creationPolicy: Owner
  data:
    - secretKey: database-url
      remoteRef:
        key: production/app/database
        property: connection_string
    - secretKey: api-key
      remoteRef:
        key: production/app/api
        property: key
  YAML

  depends_on = [
    helm_release.external_secrets,
    kubectl_manifest.vault_secret_store
  ]
}
```

## 3. Vault Secrets Operator (HashiCorp Official)

```hcl
# kubernetes/vault-secrets-operator.tf

# Install VSO
resource "helm_release" "vso" {
  name             = "vault-secrets-operator"
  repository       = "https://helm.releases.hashicorp.com"
  chart            = "vault-secrets-operator"
  namespace        = "vault-secrets-operator"
  create_namespace = true
  version          = "0.5.0"
}

# VaultConnection
resource "kubectl_manifest" "vault_connection" {
  yaml_body = <<-YAML
apiVersion: secrets.hashicorp.com/v1beta1
kind: VaultConnection
metadata:
  name: vault-connection
  namespace: vault-secrets-operator
spec:
  address: "https://vault.example.com:8200"
  skipTLSVerify: false
  caCertSecretRef:
    name: vault-ca-cert
    namespace: vault-secrets-operator
  YAML
}

# VaultAuth (Kubernetes auth)
resource "kubectl_manifest" "vault_auth" {
  yaml_body = <<-YAML
apiVersion: secrets.hashicorp.com/v1beta1
kind: VaultAuth
metadata:
  name: vault-auth
  namespace: production
spec:
  vaultConnectionRef: vault-connection
  method: kubernetes
  mount: kubernetes
  kubernetes:
    role: app-role
    serviceAccount: app-service-account
  YAML
}

# VaultStaticSecret (sync KV secrets)
resource "kubectl_manifest" "app_config" {
  yaml_body = <<-YAML
apiVersion: secrets.hashicorp.com/v1beta1
kind: VaultStaticSecret
metadata:
  name: app-config
  namespace: production
spec:
  type: kv-v2
  mount: secret
  path: production/app/config
  dest: create
  refreshAfter: 24h
  vaultAuthRef: vault-auth
  metadata:
    name: app-config-secret
  YAML
}
```

## Validation Commands

```bash
# Verify ESO is running
kubectl get pods -n external-secrets-system

# Check ClusterSecretStore status
kubectl get clustersecretstore vault-backend

# Verify ExternalSecret synced
kubectl get externalsecret -n production

# Check VSO status
kubectl get pods -n vault-secrets-operator

# Verify VaultAuth
kubectl get vaultauth -n production
```

## Common Issues

| Issue | Cause | Fix |
|-------|-------|-----|
| ESO can't connect to Vault | Network policy or TLS | Verify `caCertSecretRef` and network policies |
| ExternalSecret not syncing | Wrong secret path | Check `key` matches Vault path exactly |
| VSO VaultAuth failing | ServiceAccount mismatch | Verify `serviceAccount` exists in namespace |
