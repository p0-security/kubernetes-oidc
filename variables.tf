variable oidc_provider {
  type = string
  description = "okta | google | azure"
  validation {
    condition     = var.oidc_provider == "okta" || var.oidc_provider == "google" || var.oidc_provider == "azure"
    error_message = "The OIDC provider can be one of: okta, google, azure"
  }
}

variable google_oidc_client_id {
  description = "The Client ID of the OAuth application created in the GCloud console. Can be empty if the OIDC provider is not \"google\""
}

variable google_oidc_client_secret {
  description = "The Client Secret of the OAuth application created in the GCloud console. Can be empty if the OIDC provider is not \"google\""
}