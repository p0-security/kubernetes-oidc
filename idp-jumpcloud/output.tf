output oidc_config {
  value = {
    client_id       = var.oauth_client_id
    client_secret   = "" # JumpCloud supports PKCE without a client secret.
    # Issuer URL from here: https://jumpcloud.com/support/sso-with-oidc
    issuer_url      = "https://oauth.id.jumpcloud.com"
    user_claim      = "email"
    # Make sure to check the "Include Groups" box in the JumpCloud console, and enter "groups" as the group attribute
    groups_claim    = "groups"
    prefix          = "jumpcloud:"
    scopes          = ["openid", "profile", "email", "offline_access"]
  }
}
