# variable jumpcloud_oidc_client_id {
#   description = "The Client ID of the SSO application created in the JumpCloud console.
# }

# module "k8s_oidc" {
#   source = "./idp-jumpcloud"
#   oauth_client_id     = var.jumpcloud_oidc_client_id
# }

# output "oidc_config" {
#   value = module.k8s_oidc.oidc_config
# }
