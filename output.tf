output "okta_oidc_config" {
  value = module.okta_oidc.oidc_config
}

output "azure_oidc_config" {
  value = module.azure_oidc.oidc_config
}

output "google_oidc_config" {
  value = module.google_oidc.oidc_config
}