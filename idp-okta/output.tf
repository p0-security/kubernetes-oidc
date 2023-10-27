output oidc_config {
  value = {
    client_id       = okta_app_oauth.k8s_oidc_demo.client_id
    client_secret   = "" # Okta supports PKCE without a client secret
    issuer_url      = okta_auth_server.oidc_auth_server.issuer
    user_claim      = "email"
    groups_claim    = "groups"
    prefix          = "okta:"
    scopes          = okta_auth_server_policy_rule.auth_policy_rule.scope_whitelist
  }
}
