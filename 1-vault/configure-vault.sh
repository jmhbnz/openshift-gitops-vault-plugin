#!/bin/sh

# Enable the kubernetes auth method
vault auth enable kubernetes

# Write kubernetes auth configuration
vault write auth/kubernetes/config \
    token_reviewer_jwt="$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" \
    kubernetes_host="https://$KUBERNETES_PORT_443_TCP_ADDR:443" \
    kubernetes_ca_cert=@/var/run/secrets/kubernetes.io/serviceaccount/ca.crt

# Enable kv secrets engine
vault secrets enable -version=2 kv

# Create our sample kv
vault kv put kv/vplugin/supersecret username="myuser" password="password"

# Create policy for secret access
vault policy write vplugin - <<EOF
path "kv/*" {
  capabilities = ["read"]
}
EOF