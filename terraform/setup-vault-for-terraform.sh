vault secrets enable transit

vault write /transit/keys/git-safe -type=rsa-4096

cat > transit-policy.hcl <<EOF
path "transit/*" {
  capabilities = [ "create", "update" ]
}
path "auth/token/create" {
  capabilities = ["create", "update"]
}
EOF

vault auth enable approle

vault write auth/approle/role/git-secrets token_ttl=5m token_max_ttl=10m token_type=default policies=”transit-policy”

vault read /auth/approle/role/git-secrets/role-id

vault write -force /auth/approle/role/git-secrets/secret-id

