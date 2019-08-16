storage_source "swift" {
  auth_url = "https://api.swift.mydomain.com/auth/v1.0",
  tenant = "123123",
  container = "vault-backend",
  username = "INSERT_USERNAME",
  password = "INSERT_PASSWORD"
}

storage_destination "file" {
  path = "/backup"
}
