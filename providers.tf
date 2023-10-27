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