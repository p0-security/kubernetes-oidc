# Terraform configurations for using OIDC with Kubernetes

This repo contains an example of using various Identity Providers (IdP)

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

1. Ensure that your IdP's Terraform provider is listed in your `terraform` block in the `required_providers` section. Follow your IdP's specific Terraform provider documentation to set this up.

   - [Okta provider](https://registry.terraform.io/providers/okta/okta/latest/docs)
   - [Microsoft Entra ID provider](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs)
   - Google Workspace: provider not available TODO follow steps in blog post
   - JumpCloud: provider not available TODO follow steps in blog post

2. Copy your IdP's Terraform module from this repo into your Terraform repo root. Execute from this repo:

   ```sh
   export TF_REPO_ROOT=changeme
   export IDP=changeme # okta | azure | google | jumpcloud
   cp -R idp-$IDP $TF_REPO_ROOT/k8s-oidc
   cp main-idp-$IDP.tf $TF_REPO_ROOT/
   ```

   In addition:
   
   - If **Google Workspace** is your IdP, define the input variables `google_oidc_client_id` and `google_oidc_client_secret` in your root Terraform module and provide these values after following the manual setup steps from step 1.
   - If **JumpCloud** is your IdP, define the input variable `jumpcloud_oidc_client_id` in your root Terraform module and provide these values after following the manual setup steps from step 1. 
   - If **Okta** or **Microsoft Entra ID** (formerly Azure AD) is your IdP, no additional steps

3. Change the Terraform module that declares your Kubernetes cluster

   - If **GCloud** is your cloud provider:

     Add an `identity_service_config { enabled = true }` block to your `google_container_cluster` resource.

   - If **AWS** is your cloud provider:

     Identify which Terraform module contains your `aws_eks_cluster` resource. Execute from this repo:

     ```
     export TF_EKS_MODULE_FOLDER=changeme
     cp k8s/aws/variables.tf $TF_EKS_MODULE_FOLDER/oidc-variables.tf
     cp k8s/aws/oidc.tf $TF_EKS_MODULE_FOLDER/oidc.tf
     ```

     In your repo, edit the `cluster_name` property of the `aws_eks_identity_provider_config` resource in the copied `oidc.tf` file to point to your EKS cluster.

     In your repo, in the declaration of your Terraform module that contains the `aws_eks_cluster`, wire the output variable of the IdP module to the input variable of your consumer module. E.g.:

     ```
     module "my_eks" {
       source = "./my-eks-source"
       oidc_config = module.k8s_oidc.oidc_config
     }
     ```

4. Run `terraform init && terraform apply` in your repo to initialize and apply the new modules

   In addition:

   - If **GCloud** is your cloud provider, follow the README in `k8s/gcloud` to configure your Kubernetes services with the parameters of your IdP.
   - If **AWS** is your cloud provider, no additional steps

## ✋ Add Users to Your OIDC application

Depending on your IdP, you may need to assign users to your k8s OIDC application.

- In Okta, Microsoft Entra, and JumpCloud, assign users and user groups to the application you created with Terraform
- In Google Workspace all users are allowed to authenticate to your k8s cluster; you control access in your k8s authorization configuration

## 🛂 Configure k8s Authorization

In order for users to access Kubernetes, you need to map them to cluster roles using cluster role bindings.

Copy `clusterrolebinding.yaml` and edit to suit your needs, then:

```
kubectl apply -f clusterrolebinding.yaml
```

## 💝 Share with Developers

Run your cloud provider's corresponding kube-config generation script in the `kubectl-config-script` folder. Copy it into your repo because it reads the Terraform output. Execute from this repo:

```
export TF_REPO_ROOT=changeme
cp -R kubectl-config-script $TF_REPO_ROOT/
```

- If **AWS** is your cloud provider, find the _cluster name_ and _region_ of your Kubernetes cluster in EKS. Make sure you are using an AWS CLI profile that has AWS permissions to describe the EKS cluster. Execute from your repo:

  ```
  cluster=changeme region=changeme ./kubectl-config-script/aws-eks.sh > setup-k8s-oidc.sh
  chmod 755 setup-k8s-oidc.sh
  ```

- If **GCloud** is your cloud provider, make sure you are in a kube context that can read ClientConfig objects in the kube-public namespace. Execute from your repo (cluster name will only be used as the kube context name for OIDC access):

  ```
  cluster=changeme ./kubectl-config-script/gcloud-gke.sh > setup-k8s-oidc.sh
  chmod 755 setup-k8s-oidc.sh
  ```

Now distribute the `setup-k8s-oidc.sh` script to your developers. Note that the script will automatically install the kubelogin plugin for developers using MacOS; developers using
Windows or Linux will need to install [krew](https://github.com/kubernetes-sigs/krew) prior to running this script.
