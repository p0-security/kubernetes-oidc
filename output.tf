output "okta_oidc_config" {
  value = module.okta_oidc.oidc_config
}

output "azure_oidc_config" {
  value = module.azure_oidc.oidc_config
  sensitive = true  # Not sensitive in reality. But secret is required by Azure's OAuth flow.
}

output "google_oidc_config" {
  value = module.google_oidc.oidc_config
}