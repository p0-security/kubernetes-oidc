#!/bin/bash

# Start parameter validation
if [[ -z $cluster ]]
  then echo Argument "cluster" is required; exit 1;
fi

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

if [[ -z $scope ]]
  then echo Argument "scope" - space-separated list of scopes - is required; exit 1;
fi

if [[ -z $server ]]
  then echo Argument "server" is required; exit 1;
fi

if [[ -z $ca_data ]]
  then echo Argument "ca_data" is required; exit 1;
fi
# End parameter validation

current_dir=$(dirname "$0")

>&2 echo <<EOF
Distribute these commands to your developers:
---

EOF

# If your IdP is Google Workspace, the secret is required, which is ensured by checking the issuer value during parameter validation
if [[ -z $client_secret ]]; then
  envsubst < $current_dir/set-credentials.sh
else
  envsubst < $current_dir/set-credentials-with-secret.sh
fi
