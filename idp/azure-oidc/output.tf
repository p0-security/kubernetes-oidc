data "azuread_client_config" "current" {}


output oidc_config {
  value = {
    client_id       = azuread_application.azure_app_oauth.application_id
    client_secret   = azuread_application_password.oauth_client_secret.value
    issuer_url      = "https://login.microsoftonline.com/${data.azuread_client_config.current.tenant_id}/v2.0"
    # TODO should use `sub` claim but it's not human readable: https://learn.microsoft.com/en-us/azure/active-directory/develop/id-token-claims-reference#use-claims-to-reliably-identify-a-user
    user_claim      = "preferred_username"
    groups_claim    = "groups"
    prefix          = "azure:"
    scopes          = ["openid", "profile", "email", "offline_access"]
  }
}
