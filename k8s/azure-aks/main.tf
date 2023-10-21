resource "azurerm_resource_group" "aks_oidc_demo_resource_group" {
  name     = "aks-oidc-demo-resource-group"
  location = "West US"
}

resource "azurerm_kubernetes_cluster" "aks_oidc_demo_cluster" {
  name                = "aks-oidc-demo-cluster" # TODO kebab-case
  location            = azurerm_resource_group.aks_oidc_demo_resource_group.location
  resource_group_name = azurerm_resource_group.aks_oidc_demo_resource_group.name
  dns_prefix          = "oidcdemo"

  default_node_pool {
    name       = "oidcdemopool"
    node_count = 1
    vm_size    = "Standard_B4ms"
    enable_node_public_ip = false
  }

  identity {
    type = "SystemAssigned"
  }
   
  private_cluster_enabled = false

  # Also allow regular RBAC for administering the cluster
  role_based_access_control_enabled   = true
}
