path "transit/*" {
  capabilities = [ "create", "update" ]
}
path "auth/token/create" {
  capabilities = ["create", "update"]
}