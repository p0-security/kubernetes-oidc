#!/bin/bash

if [[ -z $cluster ]]
  then echo Argument "cluster" is required; exit 1;
fi

if [[ -z $scope ]]
  then echo Argument "scope" - space-separated list of scopes - is required; exit 1;
fi

current_dir=$(dirname "$0")
resource_dir=$current_dir/resources

client_config=$(kubectl get clientconfig default -n kube-public -o json)

issuer=$(echo $client_config | jq -r '.spec.authentication[0] | select(.name == "oidc") | .oidc.issuerURI')
client_id=$(echo $client_config | jq -r '.spec.authentication[0] | select(.name == "oidc") | .oidc.clientID')
client_secret=$(echo $client_config | jq -r '.spec.authentication[0] | select(.name == "oidc") | .oidc.clientSecret')
server=$(echo $client_config | jq -r '.spec.server')
ca_data=$(echo $client_config | jq -r '.spec.certificateAuthorityData')

cluster=$cluster issuer=$issuer client_id=$client_id client_secret=$client_secret scope=$scope server=$server ca_data=$ca_data $resource_dir/generate-kube-config.sh
