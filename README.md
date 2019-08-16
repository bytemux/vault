# vault

# Usage cases
- [x] Store secrets in k8s
  - deploy pod gets secrets from vault and updates kubernetes secrets via kubectl or api
  - secrets are static
- [x] App is not vault aware
  - init pod stores or templates secrets from vault to mounted folder/file configs and exits
  - app pod mounts config volume
  - secrets are static
- [ ] App is vault aware
  - init pod gets VAULT_TOKEN for app pod
  - app has logic to query vault with VAULT_TOKEN and gets dynamic secrets
  - app has logic to renew dynamic secrets
  - sercres can be dynamic

# Guides
- [2019 example](https://github.com/lbroudoux/secured-fruits-catalog-k8s)
    - [static](https://itnext.io/adding-security-layers-to-your-app-on-openshift-part-3-secret-management-with-vault-8efd4ec29ec4)
    - [dynamic](https://itnext.io/adding-security-layers-to-your-app-on-openshift-part-4-dynamic-secrets-with-vault-b5fe1fc7709b)
- [Official OC static](https://github.com/openlab-red/hashicorp-vault-for-openshift)
  - https://blog.openshift.com/integrating-vault-with-legacy-applications/
- [Official OC static old](https://github.com/raffaelespazzoli/credscontroller)
