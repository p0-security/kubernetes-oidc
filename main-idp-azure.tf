# The provider will use credentials on you computer. 
# Run `az login` to login as a  user account.
# Use environment variable ARM_TENANT_ID to provide your Microsoft Entry tenant ID.

# provider "azuread" {}

# variable azure_oidc_security_groups {
#   type = set(string)
#   description = "List of security groups that are assigned to the OIDC application in Azure. Only these groups will be present in the \"groups\" claim of the OIDC token, provided the authenticating user is also member of the group."
# }

# module "k8s_oidc" {
#   source = "./idp-azure"
#   security_groups = var.azure_oidc_security_groups
# }

# output "oidc_config" {
#   value = module.k8s_oidc.oidc_config
# }
