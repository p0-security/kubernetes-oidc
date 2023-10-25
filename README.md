# Terraform configurations for using OIDC with Kubernetes

## Provision Infrastructure

Assumptions: you already have a GKE or EKS cluster that is provisioned via Terraform
This repo contains an example cluster for each, to demonstrate how to integrate the OIDC provider with them.

Follow these steps to modify your existing cluster definition:

1. Ensure you have a Terraform provider configured for your identity provider. 
   Follow your IdP's specific Terraform provider documentation to set this up.
  - [Okta provider](https://registry.terraform.io/providers/okta/okta/latest/docs)
  - [Microsoft Entra ID provider](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs)
  - Google Workspace: provider not available TODO follow steps in blog post
  - JumpCloud: provider not available TODO follow steps in blog post
2. Choose your IdP and copy its corresponding Terraform module from this repo into your Terraform repo
   Example: if you use Okta then copy the `idp/okta-oidc` folder
3. Declare a new Terraform module that with new folder as the source. See `main.tf` in
   this repository for example module declarations.
4. Create an OIDC input variable definition in your Terraform consumer module (_not_ the copied idp
   module). Copy-and-paste this definition:

```
# Input variable for OIDC module
variable oidc_config {
  type = object({
    client_id       = string
    client_secret   = string
    issuer_url      = string
    user_claim      = string
    groups_claim    = string
    prefix          = string
    scopes          = list(string)
  })
}
```

5. In your root Terraform, wire the output variable of the idp module to the
   input variable of your consumer module. E.g.:

```
module "my_k8s" {
  source = "./path/to/my_k8s"
  oidc_config = module.okta_oidc.oidc_config
}
```
  - If your IdP is Google Workspace, define the input variables `google_oidc_client_id` and `google_oidc_client_secret` in your root Terraform module and provide these values after following the manual setup steps in TODO blog post
  - If your IdP is JumpCloud, define the input variable `jumpcloud_oidc_client_id` in your root Terraform module and provide these values after following the manual setup steps in TODO blog post


6. Modify your Kubernetes Terraform and pass the values from the `oidc_config` to configure OIDC authentication
   - AWS: define a new `aws_eks_identity_provider_config` that takes inputs from the `oidc_config` variable.
   - GKE: add the `identity_service_config { enabled = true }` to your `google_container_cluster` resource.
7. Run `terraform init` to initialize the new module
8. Run `terraform apply` to set up everything. (Note: if your IdP is Google Workspace or JumpCloud follow the manual steps in TODO blog post)

## Add Users to Your OIDC Provider

Depending on your IdP, you may need to assign users to provisioning.

- In Okta, Microsoft Entra, and JumpCloud, assign users and user groups to the application you created with Terraform
- In Google Workspace all users are allowed to authenticate to your k8s cluster; you control access in your k8s authorization configuration

## Configure k8s Authorization

In order for users to access Kubernetes, you need to map them to cluster roles using cluster role bindings.

Copy `clusterrolebinding.yaml` and edit to suit your needs, then:

```
kubectl apply clusterrolebinding -f clusterrolebinding.yaml
```

## Sharing with Developers

1. Run your CSP's corresponding kube-config generation script:
