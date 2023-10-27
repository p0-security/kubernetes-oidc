# Terraform configurations for using OIDC with Kubernetes
This repo contains an example of using various Identity Providers
- Okta
- Microsoft Entra ID
- Google Workspace
- JumpCloud

to authenticate against managed Kubernetes services directly:
- Kubernetes Engine (GCloud)
- Elastic Kubernetes Service (AWS)

and demonstrates how to set up OpenID Connect (OIDC) configuration.

## 🏗️ Provision Infrastructure

Assumptions: you already have a GKE (GCloud) or EKS (AWS) cluster that is provisioned via Terraform.

Follow these steps to modify your existing cluster definition:

1. Ensure you have a Terraform provider configured for your identity provider (IdP). Follow your IdP's specific Terraform provider documentation to set this up.
    - [Okta provider](https://registry.terraform.io/providers/okta/okta/latest/docs)
    - [Microsoft Entra ID provider](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs)
    - Google Workspace: provider not available TODO follow steps in blog post
    - JumpCloud: provider not available TODO follow steps in blog post
2. Copy your IdP's Terraform module from this repo into your Terraform repo root:

        TF_REPO_ROOT=changeme
        IDP=changeme # okta | azure | google | jumpcloud
        cp idp-$IDP $TF_REPO_ROOT/$IDP-oidc
        cp main-idp-$IDP.tf $TF_REPO_ROOT/

    In addition:
    - If **Google Workspace** is your IdP, define the input variables `google_oidc_client_id` and `google_oidc_client_secret` in your root Terraform module and provide these values after following the manual setup steps from setp 1.
    - If **JumpCloud** is your IdP, define the input variable `jumpcloud_oidc_client_id` in your root Terraform module and provide these values after following the manual setup steps from step 1.
    - If **Okta** or **Microsoft Entra ID** (formerly Azure AD) is your IdP, no additional steps

3. Change the Terraform module that declares your Kubernetes cluster

      - If **GCloud** is your cloud provider:

          Add an `identity_service_config { enabled = true }` block to your `google_container_cluster` resource.

      - If **AWS** is your cloud provider:

            TF_EKS_SOURCE=changeme
            cp k8s/aws/variables.tf $TF_EKS_SOURCE/oidc-variables.tf
            cp k8s/aws/oidc.tf $TF_EKS_SOURCE/oidc.tf

        Then edit the `cluster_name` property of the `aws_eks_identity_provider_config` resource in the copied `oidc.tf` file to point to your EKS cluster.

        In your root Terraform, where you declare your EKS module, wire the output variable of the IdP module to the input variable of your consumer module. E.g.:

            module "my_eks" {
              source = "./my-eks-source"
              oidc_config = module.k8s_oidc.oidc_config
            }

4. Run `terraform init && terraform apply` to initialize and apply the new modules
   
    In addition:
    - If **GCloud** is your cloud provider, follow the README in `k8s/gcloud` to configure your Kubernetes services with the parameters of your IdP.
    - If **AWS** is your cloud provider, no additional steps


## ✋ Add Users to Your OIDC Provider

Depending on your IdP, you may need to assign users to your k8s OIDC application.

- In Okta, Microsoft Entra, and JumpCloud, assign users and user groups to the application you created with Terraform
- In Google Workspace all users are allowed to authenticate to your k8s cluster; you control access in your k8s authorization configuration

## 🛂 Configure k8s Authorization

In order for users to access Kubernetes, you need to map them to cluster roles using cluster role bindings.

Copy `clusterrolebinding.yaml` and edit to suit your needs, then:

```
kubectl apply clusterrolebinding -f clusterrolebinding.yaml
```

## 💝 Share with Developers

Run your cloud provider's corresponding kube-config generation script in the `kubectl-config-script` folder:
- If **AWS** is your cloud provider, find the _cluster name_ and _region_ of your Kubernetes cluster in EKS. Make sure you are using an AWS CLI profile that has AWS permissions to describe the EKS cluster. Pass the values to the script:

       cluster=changeme region=changeme ./kubectl-config-script/aws-eks.sh

- If **GCloud** is your cloud provider, make sure you are in a kube context that can read ClientConfig objects in the kube-public namespace. Pass a cluster name to the script (it will be used as the kube context name for OIDC access):

        cluster=changeme ./kubectl-config-script/gcloud-gke.sh

The script prints the commands your developers have to run on their computer to set up OIDC access to the Kubernetes cluster.