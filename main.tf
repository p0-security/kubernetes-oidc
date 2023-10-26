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
    azuread = {
      source  = "hashicorp/azuread"
      version = "2.43.0"
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

# The provider will use credentials on you computer. 
# Run `az login` to login as a  user account.
# Use environment variable ARM_TENANT_ID to provide your Microsoft Entry tenant ID.
provider "azuread" {}

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

module "azure_oidc" {
  source = "./idp/azure-oidc"
  security_groups = var.azure_oidc_security_groups
}

module "google_oidc" {
  source = "./idp/google-oidc"
  oauth_client_id     = var.google_oidc_client_id
  oauth_client_secret = var.google_oidc_client_secret
}

module "jumpcloud_oidc" {
  source = "./idp/jumpcloud-oidc"
  oauth_client_id     = var.jumpcloud_oidc_client_id
}

locals {
  empty_config = {
      client_id       = ""
      client_secret   = ""
      issuer_url      = ""
      user_claim      = ""
      groups_claim    = ""
      prefix          = ""
      scopes          = []
  }

  oidc_config = (
    var.oidc_provider == "okta" ? 
    module.okta_oidc.oidc_config : 
    var.oidc_provider == "azure" ? 
    module.azure_oidc.oidc_config : 
    var.oidc_provider == "google" ? 
    module.google_oidc.oidc_config : 
    var.oidc_provider == "jumpcloud" ? 
    module.jumpcloud_oidc.oidc_config : 
    local.empty_config
  )
}

module "aws_eks" {
  source = "./k8s/aws-eks"
  oidc_config = module.okta_oidc.oidc_config
}

module "gcloud_gke" {
  source = "./k8s/gcloud-gke"
  oidc_config = local.oidc_config
}
