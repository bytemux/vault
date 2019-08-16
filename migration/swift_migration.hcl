storage_source "file" {
  path = "/vault/file"
}

storage_destination "swift" {
  auth_url = "https://api.swift.mydomain.com/auth/v1.0",
  tenant = "123123",
  container = "vault-backend",
  username = "INSERT_USERNAME",
  password = "INSERT_PASSWORD"
}
