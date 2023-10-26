#!/bin/bash

# Execute this script after you have deployed the OIDC Identity Service with Terraform

# Start parameter validation
if [[ -z $issuer ]]
  then echo Argument "issuer" is required; exit 1;
fi

if [[ -z $client_id ]]
  then echo Argument "client_id" is required; exit 1;
fi

if [[ $issuer == "https://accounts.google.com" ]]; then
  if [[ -z $client_secret ]]; then
    echo Argument "client_secret" is required; exit 1;
  fi
fi

if [[ -z $user_claim ]]
  then echo Argument "user_claim" is required; exit 1;
fi

if [[ -z $groups_claim ]]
  then echo Argument "groups_claim" is required; exit 1;
fi

if [[ -z $prefix ]]
  then echo Argument "prefix" is required; exit 1;
fi
# End parameter validation

current_dir=$(dirname "$0")
resource_dir=$current_dir/resources

# 1. Expose the OIDC Identity Service to the internet 
kubectl patch service gke-oidc-envoy -n anthos-identity-service --type merge --patch-file $resource_dir/expose-envoy-service-patch.yaml

# 2. Update the OIDC Configuration object with parameters from your IdP
# If your IdP is Google Workspace, the secret is required, which is ensured by checking the issuer value during parameter validation
if [[ -z $client_secret ]]; then
  envsubst < $(echo $resource_dir/client-config-patch.yaml) > $resource_dir/client-config-patch.yaml.tmp
else
  envsubst < $(echo $resource_dir/client-config-with-secret-patch.yaml) > $resource_dir/client-config-patch.yaml.tmp
fi
kubectl patch clientconfig default -n kube-public --type merge --patch-file $resource_dir/client-config-patch.yaml.tmp
rm $resource_dir/client-config-patch.yaml.tmp
