output "k8s_oidc_issuer_url" {
  value = okta_auth_server.oidc_auth_server.issuer
}

output "k8s_oidc_client_id" {
  value = okta_app_oauth.k8s_oidc_demo.client_id
}

# The "sub" claim 
output k8s_oidc_username_claim {
  value = "email"
}