# Login
```bash
export VAULT_ADDR='https://vault.mydomain.com'
export VAULT_TOKEN='INSERT_PASSWORD'
vault login
```

# Setup
```bash
VAULT_NAMESPACE="vault"
VAULT_SERVICEACCOUNT="vault-sa"

# deploy
oc new-project $VAULT_NAMESPACE
oc adm policy add-scc-to-user anyuid -z $VAULT_SERVICEACCOUNT -n $VAULT_NAMESPACE
# USE FILE BACKEND
oc create -f ./openshift/vault-swift.yaml
# USE SWIFT BACKEN - INSERT_PASSWORD
oc create -f ./openshift/vault-file.yaml
    # serviceaccount/vault-sa created
    # configmap/vault-config created
    # service/vault created
    # deploymentconfig.apps.openshift.io/vault created
    # persistentvolumeclaim/vault-file-backend created
    # route.route.openshift.io/vault created
# allow cluster-wide access
oc adm pod-network make-projects-global vault

# init
vault operator init -key-shares=1 -key-threshold=1  # default is -key-shares=5 -key-threshold=3
vault operator unseal

```

# Config

```bash
# enable k8s auth
oc adm policy add-cluster-role-to-user system:auth-delegator  system:serviceaccount:$VAULT_NAMESPACE:$VAULT_SERVICEACCOUNT
    # cluster role "system:auth-delegator" added: "system:serviceaccount:vault:vault-sa"
export SA_TOKEN=$(oc get sa/vault-sa -o yaml | grep vault-sa-token | awk '{print $3}')
export SA_JWT_TOKEN=$(oc get secret $SA_TOKEN -o jsonpath="{.data.token}" | base64 --decode; echo)
export SA_CA_CRT=$(oc get secret $SA_TOKEN -o jsonpath="{.data['ca\.crt']}" | base64 --decode; echo)
vault auth enable kubernetes
vault write auth/kubernetes/config token_reviewer_jwt="$SA_JWT_TOKEN" kubernetes_host="$(oc whoami --show-server)" kubernetes_ca_cert="$SA_CA_CRT"

# setup policy
vault policy write deploy-ro deploy-ro.hcl
vault policy write deploy-rw deploy-rw.hcl

# map policy example
## SA = myservice, namespace = mynamespace
vault write auth/kubernetes/role/myservice bound_service_account_names=myservice bound_service_account_namespaces='mynamespace' policies=deploy-ro ttl=24h
## SA = default, namespace = any (debug only)
# vault write auth/kubernetes/role/deploy-rw bound_service_account_names=default bound_service_account_namespaces='*' policies=deploy-rw ttl=24h

# setup location example
vault secrets enable -path=deploy kv-v2
vault kv put deploy/hello foo=world excited=yes
vault read deploy/data/hello -format=json | jq

# test access AS myservice:
sa_token=$(oc serviceaccounts get-token myservice -n mynamespace)
vault read deploy/data/hello -format=json jwt=${sa_token}

```

# Add autounseal (optional)
```bash
# fill INSERT_PASSWORD
oc apply -f vault-unsealer.yaml
```

# Add secret via api example
```bash
## set kv2
curl -sk --header "X-Vault-Token: $VAULT_TOKEN" --request POST --data @example.json $VAULT_ADDR/v1/deploy/data/imagepullsecret

## get kv2
curl -sk --header "X-Vault-Token: $VAULT_TOKEN" $VAULT_ADDR/v1/deploy/data/imagepullsecret > example.json
```

# Test vault access from k8s/openshift
```bash
oc run -i -t busybox --image=alpine:latest --restart=Never --rm --serviceaccount=myservice --namespace=mynamespace

apk update && apk add curl bash jq

# Via curl
VAULT_ADDR='https://vault.vault.svc'
SA_TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token);
VAULT_TOKEN=$(curl -sk --request POST --data '{"jwt": "'"$SA_TOKEN"'", "role": "myservice"}' $VAULT_ADDR/v1/auth/kubernetes/login | jq -j '.auth.client_token')
curl -sk --header "X-Vault-Token: $VAULT_TOKEN" $VAULT_ADDR/v1/deploy/data/imagepullsecret > tmp.json
kubectl delete secret imagepullsecret || true
kubectl create secret docker-registry imagepullsecret --docker-server="docker-registry.mydomain.com" --docker-username=$(jq -j '.data.data.user' tmp.json) --docker-password=$(jq -j '.data.data.password' tmp.json)

# Via vault client
export VAULT_ADDR='https://vault.vault.svc'
REGISTRY_USER=$(vault kv get -field user deploy/imagepullsecret)
REGISTRY_PASSWORD=$(vault kv get -field password deploy/imagepullsecret)
kubectl delete secret imagepullsecret || true
kubectl create secret docker-registry imagepullsecret --docker-server="docker-registry.mydomain.com" --docker-username="$REGISTRY_USER" --docker-password="$REGISTRY_PASSWORD"
```
