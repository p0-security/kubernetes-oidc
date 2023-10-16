variable oidc_config {
  type = object({
    client_id       = string
    issuer_url      = string
    user_claim      = string
    groups_claim    = string
    prefix          = string
    scopes          = list(string)
  })
}