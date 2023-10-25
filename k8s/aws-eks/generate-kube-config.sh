if [[ -z $region ]]
  then >&2 echo Argument "region" is required
  exit 1
fi

if [[ -z $cluster ]]
  then >&2 echo Argument "cluster" is required
  exit 1
fi

if [[ -z $client_secret ]]
  then >&2 echo Argument "client_secret" is required
fi

if [[ -z $scope ]]
  then >&2 echo Argument "scope" is required
  exit 1
fi

DIRECTORY=$(dirname $0)

idp_config=$(aws eks describe-identity-provider-config --profile $AWS_PROFILE --region $region --cluster-name $cluster --identity-provider-config type=oidc,name=OidcDemoConfig --output json)

issuer=$(echo $idp_config | jq -r .identityProviderConfig.oidc.issuerUrl)
client_id=$(echo $idp_config | jq -r .identityProviderConfig.oidc.clientId)
server=$(aws eks describe-cluster --region $region --name $cluster --query "cluster.endpoint" --output text)
ca_data=$(aws eks describe-cluster --region $region --name $cluster --query "cluster.certificateAuthority.data" --output text)

cluster=$cluster issuer=$issuer client_id=$client_id client_secret=$client_secret server=$server ca_data=$ca_data scope=$scope $(dirname $0)/../generate-kube-config.sh
