resource "azuread_application" "azure_app_oauth" {
  display_name = "k8s OIDC demo"

  sign_in_audience="AzureADMyOrg"
  group_membership_claims=["All"]
  fallback_public_client_enabled=true
  api {
    requested_access_token_version = 2
  }
  web {
    redirect_uris = ["http://localhost:8000/"]
  }
}

resource "azuread_application_password" "oauth_client_secret" {
  application_object_id = azuread_application.azure_app_oauth.object_id
}

# TODO how to include custom scopes/claims? The response doesn't contain email or user name, just a preferred_username...