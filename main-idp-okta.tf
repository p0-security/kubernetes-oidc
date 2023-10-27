# Use environment variables to provide credentials of the Okta provider
# E.g:
# OKTA_ORG_NAME="dev-123456"
# OKTA_BASE_URL="oktapreview.com"
# OKTA_API_TOKEN="xxxx" # create a token in the Okta Admin Console -> Security -> API -> Tokens -> Create Token

provider "okta" {}

module "k8s_oidc" {
  source = "./k8s-oidc"
}

output "oidc_config" {
  value = module.k8s_oidc.oidc_config
}