#!/bin/bash

if [[ -z $cluster ]]
  then echo Argument "cluster" is required
fi

if [[ -z $issuer ]]
  then echo Argument "issuer" is required
fi

if [[ -z $client_id ]]
  then echo Argument "client_id" is required
fi

if [[ -z $client_secret ]]
  then echo Argument "client_secret" is required
fi

if [[ -z $server ]]
  then echo Argument "server" is required
fi

if [[ -z $ca_data ]]
  then echo Argument "ca_data" is required
fi

envsubst <<EOF

Distribute these commands to your developers:
---

kubectl config set-credentials ${cluster} --exec-command=kubectl --exec-api-version=client.authentication.k8s.io/v1beta1 \\
--exec-arg="oidc-login" \\
--exec-arg="get-token" \\
--exec-arg="--oidc-issuer-url=${issuer}" \\
--exec-arg="--oidc-client-id=${client_id}" \\
--exec-arg="--oidc-client-secret=${client_secret}" \\
--exec-arg="--oidc-extra-scope=${scope}" \\
--exec-arg="--oidc-use-pkce"

kubectl config set-cluster ${cluster} --server=${server}
kubectl config set clusters.${cluster}.certificate-authority-data "${ca_data}"

kubectl config set-context ${cluster} --cluster=${cluster} --user=${cluster}

kubectl config use-context ${cluster}
EOF
