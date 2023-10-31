
# Configure OIDC
# If your IdP is Google Workspace: this block does not support specifying the client secret - however, it works without that as long as the kubectl client provides the secret

resource "aws_eks_identity_provider_config" "oidc_demo_config" {
  
  # Change this to the reference of your EKS cluster
  cluster_name = aws_eks_cluster.oidc_demo_cluster.name

  oidc {
    identity_provider_config_name = "OidcDemoConfig"
    client_id                     = var.oidc_config.client_id
    issuer_url                    = var.oidc_config.issuer_url
    username_claim                = var.oidc_config.user_claim
    groups_claim                  = var.oidc_config.groups_claim
    groups_prefix                 = var.oidc_config.prefix
    # Uncomment if you want to use the prefix for the username as well
    # username_prefix               = var.oidc_config.prefix
  }
}
