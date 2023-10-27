#!/bin/bash

if [[ -z $cluster ]]
  then echo Argument "cluster" is required. This is the name of the kube context your engineers will configure locally.; exit 1;
fi

oidc_config=$(terraform output -json oidc_config)
issuer=$(echo $oidc_config | jq -r .issuer_url)
client_id=$(echo $oidc_config | jq -r .client_id)
client_secret=$(echo $oidc_config | jq -r .client_secret)
scope=$(echo $oidc_config | jq -r '.scopes | join(" ")')

client_config=$(kubectl get clientconfig default -n kube-public -o json)
server=$(echo $client_config | jq -r '.spec.server')
ca_data=$(echo $client_config | jq -r '.spec.certificateAuthorityData')

current_dir=$(dirname "$0")
resource_dir=$current_dir/resources

cluster=$cluster issuer=$issuer client_id=$client_id client_secret=$client_secret scope=$scope server=$server ca_data=$ca_data $resource_dir/generate-kube-config.sh
