# Select which OIDC provider is configured in the Kubernetes clusters
variable oidc_provider {
  type = string
  description = "okta | google | azure | jumpcloud"
  validation {
    condition     = var.oidc_provider == "okta" || var.oidc_provider == "google" || var.oidc_provider == "azure" || var.oidc_provider == "jumpcloud"
    error_message = "The OIDC provider can be one of: okta, google, azure"
  }
}

# Azure OIDC
variable azure_oidc_security_groups {
  type = set(string)
  description = "List of security groups that are assigned to the OIDC application in Azure. Only these groups will be present in the \"groups\" claim of the OIDC token, provided the authenticating user is also member of the group."
}

# Google OIDC
variable google_oidc_client_id {
  description = "The Client ID of the OAuth application created in the GCloud console. Can be empty if the OIDC provider is not \"google\""
}

variable google_oidc_client_secret {
  description = "The Client Secret of the OAuth application created in the GCloud console. Can be empty if the OIDC provider is not \"google\""
}

# JumpCloud OIDC
variable jumpcloud_oidc_client_id {
  description = "The Client Secret of the OAuth application created in the GCloud console. Can be empty if the OIDC provider is not \"google\""
}
