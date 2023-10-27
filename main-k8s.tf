# This file is an example of a multi-cloud Kubernetes setup

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

module "aws_eks" {
  source = "./k8s/aws"
  oidc_config = module.k8s_oidc.oidc_config
}

module "gcloud_gke" {
  source = "./k8s/gcloud"
}
