# Terraform configurations for using OIDC with Kubernetes

## Provisioning Infrastructure

Assumptions: you already have a GKE or EKS cluster that is provisioned via Terraform
This repo contains an example cluster for each, to demonstrate how to integrate the OIDC provider with them.

Follow these steps to modify your existing cluster definition:

1. Ensure you have a Terraform provider configured for your identity provider. Follow your IdP's specific
   Terraform provider documentation to set this up.
2. Choose your IdP and copy its corresponding Terraform module from this repo into your Terraform repo
   Example: if you use Okta then copy the `idp/okta-oidc` folder
3. Declare a new Terraform module that points to the folder. See `main.tf` in
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

6. Modify your Kubernetes Terraform and pass the values from the `oidc_config` to configure OIDC authentication
   1. AWS: define a new `aws_eks_identity_provider_config` that takes inputs from the `oidc_config` variable.
   2. GKE:
      Something something stubs
7. Run Terraform init.
8. Apply your Terraform.

## Add Users to Your OIDC Provider

Depending on your IdP, you may need to assign users to provisioning.

- In Okta and Microsoft Entra, assign users and user groups to the app you created in Terraform
- For providers like Google Workspace, all users will be allowed to authenticate to your k8s cluster; you will need to control access in your k8s authorization configuration

## Configure k8s Authorization

In order for users to access Kubernetes, you need to map them to cluster roles using cluster role bindings.

Copy `clusterrolebinding.yaml` and edit to suit your needs, then:

```
kubectl apply clusterrolebinding -f clusterrolebinding.yaml
```

## Sharing with Developers

1. Run your CSP's corresponding kube-config generation script:
