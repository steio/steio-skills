# Kubernetes Vault Integration with External Secrets Operator

## Setup

- Kubernetes cluster (1.24+)
- HashiCorp Vault (>= 1.15) accessible from cluster
- Helm installed
- Terraform/OpenTofu with providers:
  - `hashicorp/helm`
  - `hashicorp/vault`
  - `gavinbunney/kubectl` or `mumoshu/kubectl`

## Task

Configure Kubernetes to consume secrets from HashiCorp Vault using External Secrets Operator (ESO) with:

1. **ESO Installation** via Helm:
   - Version 0.9.x
   - CRDs installed
   - ESO namespace created

2. **Vault Setup**:
   - Enable Kubernetes auth method
   - Create service account for ESO
   - Create Vault role bound to service account
   - Store test secret in KV v2

3. **ClusterSecretStore**:
   - Connect ESO to Vault
   - Use Kubernetes auth method
   - Point to `secret` KV v2 engine

4. **ExternalSecret**:
   - Sync secrets from Vault to Kubernetes
   - Use appropriate `refreshInterval`
   - Create secret in `production` namespace

5. **Application Pod**:
   - Reference Kubernetes secret via `envFrom`
   - Show proper secret injection pattern

## Expected Behavior

1. ESO installed and running
2. Vault Kubernetes auth configured with proper bindings
3. ClusterSecretStore connects ESO to Vault
4. ExternalSecret syncs Vault secrets to Kubernetes
5. Application pod consumes secrets via standard K8s mechanisms

## Validation

- [ ] `helm_release` for ESO installation
- [ ] `vault_kubernetes_auth_backend_config` resource
- [ ] `vault_kubernetes_auth_backend_role` with proper bindings
- [ ] `vault_kv_secret_v2` for test secret
- [ ] `kubectl_manifest` or `kubectl_manifest` for ClusterSecretStore
- [ ] `kubectl_manifest` for ExternalSecret
- [ ] Pod spec using `envFrom` with `secretRef`
- [ ] Proper `refreshInterval` set
