#Author: Nijo Varghese
---
sudo mkdir /users
cd /users/


CREATE A KUBECONFIG for user CHARLIE

export user=charlie
export group=cluster-reader
export namespace=default
export CA_KEY=/etc/kubernetes/pki/ca.key
export CA_CERT=/etc/kubernetes/pki/ca.crt
export MY_KEY=${user}.key
export MY_CRT=${user}.crt
export MY_CSR=${user}.csr
export MASTER_DNS_NAME=k8s-api.virtual.local
export MASTER_PORT=6443
export CLUSTER_NAME=dev-cluster
export CONTEXT_NAME=dev-cluster

openssl genrsa -out ${user}.key 2048   #Key
openssl req -new -key ${user}.key -out ${user}.csr -subj "/CN=${user}/O=${group}"  #csr
openssl x509 -req -in ${user}.csr  -CA ${CA_CERT} -CAkey ${CA_KEY}  -CAcreateserial -out ${user}.crt -days 365
openssl x509 -in ${user}.crt -text -noout
openssl rsa  -in ${user}.key -check
export TOKEN=$(dd if=/dev/urandom bs=128 count=1 2>/dev/null | base64 | tr -d "=+/" | dd bs=32 count=1 2>/dev/null)

kubectl create secret generic ${user}-certs --from-file=/users/${user}.crt -n kube-system
kubectl -n kube-system get secret | grep cluster-admin


PROVIDE DASHBOARD ACCESS to USER CHARLIE

kubectl create -f role-deployment-manager.yaml
kubectl create -f rolebinding-deployment-manager.yaml
kubectl apply -f dashboard-sa.yaml
kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep charlie | awk '{print $1}')

