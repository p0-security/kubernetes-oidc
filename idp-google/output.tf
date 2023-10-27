output oidc_config {
  value = {
    client_id       = var.oauth_client_id
    client_secret   = var.oauth_client_secret
    issuer_url      = "https://accounts.google.com"
    user_claim      = "email"
    groups_claim    = "groups"
    prefix          = "google:"
    scopes          = ["openid", "https://www.googleapis.com/auth/userinfo.profile", "https://www.googleapis.com/auth/userinfo.email"]
  }
}
