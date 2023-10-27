# variable jumpcloud_oidc_client_id {
#   description = "The Client Secret of the OAuth application created in the GCloud console. Can be empty if the OIDC provider is not \"google\""
# }

# module "k8s_oidc" {
#   source = "./idp-jumpcloud"
#   oauth_client_id     = var.jumpcloud_oidc_client_id
# }

# output "oidc_config" {
#   value = module.k8s_oidc.oidc_config
# }
