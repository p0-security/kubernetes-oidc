#!/bin/bash

if [[ -z $cluster ]]; then
  echo Argument "cluster" is required. This is the cluster name of the EKS Kubernetes cluster you are configurig developer access to. It is also used as the name of the kube context your engineers will configure locally.; exit 1;
fi

if [[ -z $region ]]; then
  echo Argument "region" is required. This is the AWS region where your EKS Kubernetes cluster is hosted.; exit 1;
fi

oidc_config=$(terraform output -json oidc_config)

issuer=$(echo $oidc_config | jq -r .issuer_url)
client_id=$(echo $oidc_config | jq -r .client_id)
client_secret=$(echo $oidc_config | jq -r .client_secret)
scope=$(echo $oidc_config | jq -r '.scopes | join(" ")')

server=$(aws eks describe-cluster --region $region --name $cluster --query "cluster.endpoint" --output text)
ca_data=$(aws eks describe-cluster --region $region --name $cluster --query "cluster.certificateAuthority.data" --output text)

current_dir=$(dirname "$0")
resource_dir=$current_dir/resources

cluster=$cluster issuer=$issuer client_id=$client_id client_secret=$client_secret server=$server ca_data=$ca_data scope=$scope $resource_dir/generate-kube-config.sh
