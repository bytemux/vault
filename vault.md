# mgmt

## Login
export VAULT_ADDR='https://vault.mydomain.com'
export VAULT_TOKEN='INSERT_TOKEN'

vault login $VAULT_TOKEN
vault status
vault secrets list
vault path-help database/

## Init
vault operator init -status
vault operator init

## Rekey
vault operator rekey -init -key-shares=1 -key-threshold=1
vault operator rekey

## Unseal
vault operator unseal

## Manual mgmt
https://www.vaultproject.io/docs/commands/index.html
vault secrets enable -path=secret kv-v2
vault kv put secret/hello foo=world excited=yes
vault kv get secret/hello
vault kv get -field=excited secret/hello
vault kv get -format=json secret/hello | jq -r .data.excited

## Will revoke all secrets!
vault secrets disable kv/
or
vault move kv/ newpath/

# auth
vault auth list
vault auth enable -path=github github
vault auth help github
vault login -method=github

# policy
vault policy list
vault policy write <file>
vault write sys/policy/deploy-ro policy=@deploy-ro.hcl

vault write auth/kubernetes/role/myservice bound_service_account_names=myservice bound_service_account_namespaces='mynamespace' policies=spring-native-example ttl=2h

## troubleshoot permissions
vault token create -policy=my-policy
vault login INSERT_PASSWORD

# Storage & backup
https://www.vaultproject.io/docs/configuration/storage/swift.html
https://www.vaultproject.io/docs/commands/operator/migrate.html

vault operator migrate -config=file_backup.hcl

# Auto-unseal
- https://github.com/jaxxstorm/hookpick
- autounseal.sh + custom docker image

---

# change root roken
```bash
# create new
vault operator generate-root -init
vault operator generate-root
vault operator generate-root \
  -decode=INSERT_PASSWORD \
  -otp=INSERT_PASSWORD \

# revoke old
vault token lookup
vault token revoke -self
```

# change seal key
```bash
vault operator rekey -init -key-shares=1 -key-threshold=1
vault operator rekey

```
