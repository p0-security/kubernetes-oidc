### Use an OIDC provider with your Kubernetes cluster

Assumptions: you already have a GKE or EKS cluster that is provisioned via Terraform
This repo contains an example cluster for each, to demonstrate how to integrate the OIDC provider with them.

Follow these steps to modify your existing cluster definition:
1. Choose your IdP and copy its corresponding Terraform module from this repo into your Terraform repo
Example: if you use Okta then copy the `idp/okta-oidc` folder
2. Declare a new Terraform module that points to the folder. See `main.tf` for the module declarations.
3. The IdP module exports one object: the OIDC configuration of the format:
```
output oidc_config {
  value = {
    client_id       = {client_id}
    client_secret   = {client_secret}
    issuer_url      = {issuer_url}
    user_claim      = {user_claim}
    groups_claim    = {groups_claim}
    prefix          = {prefix}
    scopes          = [...{scopes}]
  }
}
```

4. Define a new input variable for your Kubernetes Terraform module

5. Modify your Kubernetes Terraform and pass the values from the `oidc_config` to configure OIDC authentication
    1. AWS: define a new `aws_eks_identity_provider_config` that takes inputs from the `oidc_config` variable. 
    2. GKE: 

