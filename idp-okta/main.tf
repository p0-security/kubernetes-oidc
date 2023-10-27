
# Based on https://developer.okta.com/blog/2021/11/08/k8s-api-server-oidc

# Need to declare the provider configuration again in the module to avoid clash with hashicorp/okta provider
terraform {
  required_providers {
    okta = {
      source = "okta/okta"
      version = "4.4.2"
    }
  }
  required_version = "= 1.5.1"
}

resource "okta_app_oauth" "k8s_oidc_demo" {
  label                      = var.oauth_app_name
  type                       = "native"
  token_endpoint_auth_method = "none"
  pkce_required              = true
  grant_types = [
    "authorization_code"
  ]
  response_types = ["code"]
  redirect_uris = [
    "http://localhost:8000"
  ]
  post_logout_redirect_uris = [
    "http://localhost:8000"
  ]
}

# Creates a claim for the auth server. See in Okta: Security -> API -> Authorization Servers -> k8s-auth -> Claims
resource "okta_auth_server" "oidc_auth_server" {
  name        = var.auth_server_name
  description = "OIDC auth server for k8s demo"
  audiences   = ["http://localhost:8000"]
}

resource "okta_auth_server_scope" "groups_scope" {
  auth_server_id   = okta_auth_server.oidc_auth_server.id
  name             = "groups"
  display_name     = "Groups claim" 
  description      = "Allows the app to view groups you are member of"
  consent          = "IMPLICIT"
  metadata_publish = "ALL_CLIENTS"
}

resource "okta_auth_server_claim" "groups_claim" {
  name                    = "groups"
  auth_server_id          = okta_auth_server.oidc_auth_server.id
  always_include_in_token = true
  claim_type              = "IDENTITY"
  scopes                  = [okta_auth_server_scope.groups_scope.name]
  value_type              = "GROUPS"
  group_filter_type       = "REGEX"
  value                   = var.group_regex_filter
}

resource "okta_auth_server_policy" "auth_policy" {
  name             = "k8s_policy"
  auth_server_id   = okta_auth_server.oidc_auth_server.id
  description      = "Policy for allowed clients"
  priority         = 1
  client_whitelist = [okta_app_oauth.k8s_oidc_demo.id]
}

resource "okta_auth_server_policy_rule" "auth_policy_rule" {
  name           = "AuthCode + PKCE"
  auth_server_id = okta_auth_server.oidc_auth_server.id
  policy_id      = okta_auth_server_policy.auth_policy.id
  priority       = 1
  grant_type_whitelist = [
    "authorization_code"
  ]
  scope_whitelist = ["openid", "profile", "email", okta_auth_server_scope.groups_scope.name, "offline_access"]
  group_whitelist = ["EVERYONE"]
}
