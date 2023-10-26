kubectl config set-credentials ${cluster} --exec-command=kubectl --exec-api-version=client.authentication.k8s.io/v1beta1 \\
--exec-arg="oidc-login" \\
--exec-arg="get-token" \\
--exec-arg="--oidc-issuer-url=${issuer}" \\
--exec-arg="--oidc-client-id=${client_id}" \\
--exec-arg="--oidc-extra-scope=${scope}" \\
--exec-arg="--oidc-use-pkce"

kubectl config set-cluster ${cluster} --server=${server}
kubectl config set clusters.${cluster}.certificate-authority-data "${ca_data}"

kubectl config set-context ${cluster} --cluster=${cluster} --user=${cluster}

kubectl config use-context ${cluster}