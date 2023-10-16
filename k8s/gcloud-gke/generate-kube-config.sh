#!/bin/bash

if [[ -z $cluster ]]
  then echo Argument "cluster" is required
fi

if [[ -z $client_secret ]]
  then echo Argument "client_secret" is required
fi

if [[ -z $scope ]]
  then echo Argument "scope" is required
fi

client_config=$(kubectl get clientconfig default -n kube-public -o json)

issuer=$(echo $client_config | jq -r '.spec.authentication[0] | select(.name == "oidc") | .oidc.issuerURI')
client_id=$(echo $client_config | jq -r '.spec.authentication[0] | select(.name == "oidc") | .oidc.clientID')
server=$(echo $client_config | jq -r '.spec.server')
ca_data=$(echo $client_config | jq -r '.spec.certificateAuthorityData')

cluster=$cluster issuer=$issuer client_id=$client_id client_secret=$client_secret server=$server ca_data=$ca_data scope=$scope ../generate-kube-config.sh
