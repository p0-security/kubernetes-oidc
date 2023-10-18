resource "azuread_application" "azure_app_oauth" {
  display_name = "k8s OIDC demo"

  sign_in_audience="AzureADMyOrg"
  group_membership_claims=["ApplicationGroup"]
  fallback_public_client_enabled=false
  api {
    requested_access_token_version = 2
  }
  public_client {
    redirect_uris = ["http://localhost:8000/"]
  }

  optional_claims {
    access_token {
      name                  = "groups"
      additional_properties = ["cloud_displayname"]
    }
    id_token {
      name                  = "groups"
      additional_properties = ["cloud_displayname"]
    }
  }
}

data "azuread_service_principal" "app_principal" {
  application_id = azuread_application.azure_app_oauth.application_id
}

module "group_to_app_assignment" {
  for_each = var.security_groups

  source = "./assignment"
  app_object_id = data.azuread_service_principal.app_principal.object_id
  security_group_display_name = each.value
}
