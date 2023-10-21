This folder is a separate Terraform project for deploying the OIDC provider as a Kubernetes workload into the AKS cluster.

Once the AKS cluster has been created:
1. Download Kubernetes client credentials with `az aks get-credentials --resource-group aks-oidc-demo-resource-group --name aks-oidc-demo-cluster --context aks-oidc-demo`
2. Execute `terraform init` and `terraform apply` from this folder

