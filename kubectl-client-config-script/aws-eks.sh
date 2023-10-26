#!/bin/bash

if [[ -z $region ]]
  then echo Argument "region" is required; exit 1;
fi

if [[ -z $cluster ]]
  then echo Argument "cluster" is required; exit 1;
fi

# If IdP is Google workspace then the client secret has to passed.
# The secret cannot be stored in the OIDC config in EKS, a client_secret doesn't exist.
if [[ $issuer == "https://accounts.google.com" ]]; then
  if [[ -z $client_secret ]]; then
    echo Argument "client_secret" is required; exit 1;
  fi
fi

if [[ -z $scope ]]
  then echo Argument "scope" - space-separated list of scopes - is required; exit 1;
fi

current_dir=$(dirname "$0")
resource_dir=$current_dir/resources

idp_config=$(aws eks describe-identity-provider-config --region $region --cluster-name $cluster --identity-provider-config type=oidc,name=OidcDemoConfig --output json)

issuer=$(echo $idp_config | jq -r .identityProviderConfig.oidc.issuerUrl)
client_id=$(echo $idp_config | jq -r .identityProviderConfig.oidc.clientId)
server=$(aws eks describe-cluster --region $region --name $cluster --query "cluster.endpoint" --output text)
ca_data=$(aws eks describe-cluster --region $region --name $cluster --query "cluster.certificateAuthority.data" --output text)

cluster=$cluster issuer=$issuer client_id=$client_id client_secret=$client_secret server=$server ca_data=$ca_data scope=$scope $resource_dir/generate-kube-config.sh
