# variable google_oidc_client_id {
#   description = "The Client ID of the OAuth application created in the GCloud console. Can be empty if the OIDC provider is not \"google\""
# }

# variable google_oidc_client_secret {
#   description = "The Client Secret of the OAuth application created in the GCloud console. Can be empty if the OIDC provider is not \"google\""
# }

# module "k8s_oidc" {
#   source = "./idp-google"
#   oauth_client_id     = var.google_oidc_client_id
#   oauth_client_secret = var.google_oidc_client_secret
# }

# output "oidc_config" {
#   value = module.k8s_oidc.oidc_config
# }


