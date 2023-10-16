#!/bin/bash

if [[ -z $issuer ]]
  then echo Argument "issuer" is required
fi

if [[ -z $client_id ]]
  then echo Argument "client_id" is required
fi

if [[ -z $user_claim ]]
  then echo Argument "user_claim" is required
fi

if [[ -z $groups_claim ]]
  then echo Argument "groups_claim" is required
fi

if [[ -z $prefix ]]
  then echo Argument "prefix" is required
fi

envsubst < $(echo client-config-patch.yaml) > client-config-patch.yaml.tmp
kubectl patch clientconfig default -n kube-public --type merge --patch-file client-config-patch.yaml.tmp
rm client-config-patch.yaml.tmp
