data "azuread_client_config" "current" {}


output oidc_config {
  value = {
    client_id       = azuread_application.azure_app_oauth.application_id
    # The "Mobile and desktop applications" application type errors if a secret is provided because the client is assumed to be public.
    client_secret   = ""
    issuer_url      = "https://login.microsoftonline.com/${data.azuread_client_config.current.tenant_id}/v2.0"
    # Should use `sub` claim but it's not human readable: https://learn.microsoft.com/en-us/azure/active-directory/develop/id-token-claims-reference#use-claims-to-reliably-identify-a-user
    # "preferred_username" is the UPN of the user, used for login as well. It is unique at any point in time but can be reused.
    user_claim      = "preferred_username"
    groups_claim    = "groups"
    prefix          = "azure:"
    scopes          = ["openid", "profile", "email", "offline_access"]
  }
}
