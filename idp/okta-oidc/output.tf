output oidc_config {
  value = {
    client_id       = okta_app_oauth.k8s_oidc_demo.client_id
    client_secret   = "" # unused
    issuer_url      = okta_auth_server.oidc_auth_server.issuer
    user_claim      = "email"
    groups_claim    = "groups"
    prefix          = "okta:"
    scopes          = ["openid", "profile", "email", "groups", "offline_access"]
  }
}
