terraform {
  required_providers {
    okta = {
      source = "okta/okta"
      version = "4.4.2"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "5.0" # TODO update to 5.19.0
    }
    google = {
      source  = "hashicorp/google"
      version = "5.0.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "5.0.0"
    }
  }
  required_version = "= 1.5.1"
}

# Use environment variables to provide credentials of the Okta provider
# E.g:
# OKTA_ORG_NAME="dev-123456"
# OKTA_BASE_URL="oktapreview.com"
# OKTA_API_TOKEN="xxxx" # create a token in the Okta Admin Console -> Security -> API -> Tokens -> Create Token
provider "okta" {}

# Use environment variable AWS_PROFILE to provide credentials of the AWS provider.
# E.g:
# AWS_PROFILE="dev"
provider "aws" {
  region = "us-west-2"
}

# The provider will use the default credentials of the environment. Run `gcloud auth application-default login` to login.
# See https://registry.terraform.io/providers/hashicorp/google/latest/docs/guides/provider_reference
# Use environment variables to configure project and region.
# E.g:
# GCLOUD_PROJECT="dev-123456"
# GCLOUD_REGION="us-west2"
provider "google" {}
provider "google-beta" {}



module "okta_oidc" {
  source = "./idp/okta-oidc"
}

module "aws_eks" {
  source = "./k8s/aws-eks"

  k8s_oidc_client_id       = module.okta_oidc.k8s_oidc_client_id
  k8s_oidc_issuer_url      = module.okta_oidc.k8s_oidc_issuer_url
  k8s_oidc_username_claim  = module.okta_oidc.k8s_oidc_username_claim
  k8s_oidc_username_prefix = "okta:"
  k8s_oidc_groups_claim    = "groups"
  k8s_oidc_groups_prefix   = "okta:"
}

module "gcloud_gke" {
  source = "./k8s/gcloud-gke"
}
