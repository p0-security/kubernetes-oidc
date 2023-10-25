# Dedicated VPC for the GKE cluster
resource "google_compute_network" "oidc_demo_gke_vpc_network" {
  name                    = "oidc-demo-gke-vpc-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "oidc_demo_gke_vpc_subnet" {
  name          = "oidc-demo-gke-vpc-network-subnet"
  network       = google_compute_network.oidc_demo_gke_vpc_network.id
  ip_cidr_range = "10.138.0.0/20"
}

# Service account
resource "google_service_account" "gke_cluster_service_account" {
  account_id   = "oidc-demo-gke-sa"
  display_name = "OIDC Demo GKE service account"
}

# Cluster
resource "google_container_cluster" "oidc_demo_gke_cluster" {
  provider = google-beta # Beta required for identity_service_config block
  name     = "oidc-demo-gke-cluster"

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it. Source: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_node_pool
  remove_default_node_pool = true
  initial_node_count       = 1

  network    = google_compute_network.oidc_demo_gke_vpc_network.name
  subnetwork = google_compute_subnetwork.oidc_demo_gke_vpc_subnet.name

  networking_mode = "VPC_NATIVE"
  ip_allocation_policy {
    # These must not overlap with each other and the `private_cluster_config.master_ipv4_cidr_block` range
    cluster_ipv4_cidr_block  = "10.101.0.0/16"
    services_ipv4_cidr_block = "10.102.0.0/16"
  }

  private_cluster_config {
    # Nodes only have private IP and communicate with control plane over private IP
    enable_private_nodes = true
    # Public control plan endpoint
    enable_private_endpoint = false
    master_global_access_config {
      enabled = true
    }
    # When creating a private cluster, the `master_ipv4_cidr_block` has to be defined and the size must be /28
    master_ipv4_cidr_block = "10.100.100.0/28"
  }

  # Disable ABAC
  enable_legacy_abac = false

  # Disable issuing a client certificate
  master_auth {
    client_certificate_config {
      issue_client_certificate = false
    }
  }
  
  # Enable the identity service component. See https://cloud.google.com/kubernetes-engine/docs/how-to/oidc
  # Run the manual steps in the scripts/ folder to configure the identity service with your provider
  identity_service_config {
    enabled = true
  }
}

# Separately manage node pool - we need a node pool because the Identity Service runs as a Kubernetes Deployment.
resource "google_container_node_pool" "oidc_demo_gke_cluster_nodes" {
  name       = "oidc-demo-gke-cluster-nodes"
  cluster    = google_container_cluster.oidc_demo_gke_cluster.id
  node_count = 1

  node_config {
    service_account = google_service_account.gke_cluster_service_account.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]

    preemptible  = false
    machine_type = "e2-medium"
    tags         = ["oidc-demo-gke-cluster-nodes"]
    metadata = {
      disable-legacy-endpoints = "true"
    }
  }
}

# Cloud NAT to allow internet access (for calling OpenID Discovery Endpoint) from the Kubernetes cluster
resource "google_compute_router" "oidc_demo_router" {
  name    = "oidc-demo-router"
  network = google_compute_network.oidc_demo_gke_vpc_network.self_link
  bgp {
    // Local BGP Autonomous System Number (ASN). Must be an RFC6996 private ASN, either 16-bit or 32-bit. 
    // The value will be fixed for this router resource. All VPN tunnels that link to this router will have the same local ASN.
    // See https://cloud.google.com/network-connectivity/docs/router/how-to/create-router-vpc-network#create_a
    // TL;DR The ASN can be any private ASN that you aren't already using as a peer ASN in the same region and network
    asn                = 64514
    keepalive_interval = 20
  }
}

resource "google_compute_router_nat" "router_nat" {
  name                               = "oidc-demo-router-nat"
  router                             = google_compute_router.oidc_demo_router.name
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}


  # The ClientConfig object must be updated after enabling identity service based on the OIDC config in the identity provider
  # TODO this provisioner should run with credentials from the k8s cluster
  resource "null_resource" "k8s_oidc_client_config_patch" {
   
    triggers = {
      issuer       = var.oidc_config.issuer_url
      client_id    = var.oidc_config.client_id
      user_claim   = var.oidc_config.user_claim
      groups_claim = var.oidc_config.groups_claim
      prefix       = var.oidc_config.prefix
    }

    provisioner "local-exec" {
      command = "./apply-client-config-patch.sh"
      working_dir = "./k8s/gcloud-gke/client-config-patch"
      environment = {
        issuer       = var.oidc_config.issuer_url
        client_id    = var.oidc_config.client_id
        user_claim   = var.oidc_config.user_claim
        groups_claim = var.oidc_config.groups_claim
        prefix       = var.oidc_config.prefix
      }
    }

  depends_on = [ google_container_cluster.oidc_demo_gke_cluster ]
}
