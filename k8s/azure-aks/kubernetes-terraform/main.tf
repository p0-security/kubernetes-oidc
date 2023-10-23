terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes",
      version = "2.23.0"
    }
  }
  required_version = "= 1.5.1"
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "aks-oidc-demo"
}

locals {
  volume_name = "kube-oidc-proxy-tls"
  dns_label = "aks-oidc-demo"
  host_name = "${local.dns_label}.westus.cloudapp.azure.com"
}

resource "kubernetes_namespace" "kube_oidc" {
  metadata {
    name = "kube-oidc"
  }
}

resource "kubernetes_service_account" "kube_oidc_proxy_sa" {
  metadata {
    name      = "kube-oidc-proxy-sa"
    namespace = kubernetes_namespace.kube_oidc.metadata[0].name
  }
}

resource "tls_private_key" "kube_oidc_ca_private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "tls_self_signed_cert" "kube_oidc_ca_cert" {
  private_key_pem = tls_private_key.kube_oidc_ca_private_key.private_key_pem

  subject {
    common_name  = "kube-oidc-proxy CA"
  }

  validity_period_hours = 39 * 30 * 24 # ~ 39 months

  is_ca_certificate = true

  allowed_uses = [
    "digital_signature",
    "cert_signing",
    "crl_signing"
  ]
}

resource "tls_private_key" "kube_oidc_tls_private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "tls_cert_request" "kube_oidc_tls_cert_request" {
  private_key_pem = tls_private_key.kube_oidc_tls_private_key.private_key_pem

  subject {
    common_name  = local.host_name
  }
  dns_names = [local.host_name]
}

resource "tls_locally_signed_cert" "kube_oidc_tls_cert" {
  cert_request_pem   = tls_cert_request.kube_oidc_tls_cert_request.cert_request_pem
  ca_private_key_pem = tls_private_key.kube_oidc_ca_private_key.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.kube_oidc_ca_cert.cert_pem

  validity_period_hours = 39 * 30 * 24 # ~ 39 months

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
    "client_auth"
  ]
}

resource "kubernetes_secret" "kube_oidc_proxy_tls" {
  metadata {
    name      = "kube-oidc-proxy-tls"
    namespace = kubernetes_namespace.kube_oidc.metadata[0].name
  }

  type = "kubernetes.io/tls"

  data = {
    "ca.crt" = tls_self_signed_cert.kube_oidc_ca_cert.cert_pem
    "ca.key" = tls_private_key.kube_oidc_ca_private_key.private_key_pem
    "tls.crt" = tls_locally_signed_cert.kube_oidc_tls_cert.cert_pem
    "tls.key" = tls_private_key.kube_oidc_tls_private_key.private_key_pem
  }
}

resource "kubernetes_deployment" "kube_oidc_proxy" {
  metadata {
    name      = "kube-oidc-proxy"
    namespace = kubernetes_namespace.kube_oidc.metadata[0].name
    labels = {
      app = "kube-oidc"
    }
  }

  spec {
    replicas = 2
    strategy {
      type = "RollingUpdate"
    }

    selector {
      match_labels = {
        app = "kube-oidc"
      }
    }

    template {
      metadata {
        labels = {
          app = "kube-oidc"
        }
      }

      spec {

        service_account_name = kubernetes_service_account.kube_oidc_proxy_sa.metadata[0].name

        volume {
          name = local.volume_name
          secret {
            secret_name = kubernetes_secret.kube_oidc_proxy_tls.metadata[0].name
            items {
              key  = "tls.crt"
              path = "cert.pem"
            }
            items {
              key  = "tls.key"
              path = "key.pem"
            }
          }
        }

        container {
          name              = "kube-oidc-proxy"
          image             = "docker.io/tremolosecurity/kube-oidc-proxy:1.0.5-b48171"
          image_pull_policy = "Always"

          # command = ["kube-oidc-proxy"]

          args = [
            "kube-oidc-proxy",
            "--oidc-ca-file=/etc/ssl/certs/ca-certificates.crt",
            "--tls-cert-file=/etc/oidc/tls/cert.pem",
            "--tls-private-key-file=/etc/oidc/tls/key.pem",
            "--oidc-issuer-url=https://accounts.google.com",
            "--oidc-client-id=403826425907-ijjghl5b1scc38lf8h10nak1u8tphsaj.apps.googleusercontent.com",
            "--oidc-username-claim=sub",
            # "--oidc-username-prefix=google:",
            # "--oidc-groups-claim=groups",
            # "--oidc-groups-prefix=google:",
            "-v=7",
            # {{- range .Values.oidc.requiredClaims }}
            # - "--oidc-required-claim={{ . }}"
            # {{- end }}
          ]

          # security_context {
          #   allow_privilege_escalation = false
          #   capabilities {
          #     drop = ["ALL"]
          #   }
          #   privileged = false
          #   run_as_group = 65534
          #   run_as_non_root =  true
          #   run_as_user = 65534
          #   seccomp_profile {
          #     type = "RuntimeDefault"
          #   }
          # }

          resources {
            limits = {
              memory = "128Mi"
              cpu    = "500m"
            }
            requests = {
              memory = "128Mi"
              cpu    = "500m"
            }
          }

          port {
            name           = "https"
            container_port = 6443
          }

          port {
            name           = "metrics"
            container_port = 8080
          }

          startup_probe {
            http_get {
              path = "/ready"
              port = "metrics"
            } 
          }

          readiness_probe {
            http_get {
              path = "/ready"
              port = "metrics"
            } 
          }

          liveness_probe {
            http_get {
              path = "/live"
              port = "metrics"
            } 
          }

          volume_mount {
            name       = local.volume_name
            mount_path = "/etc/oidc/tls"
            read_only  = true
          }
        }
      }
    }
  }
}

resource "kubernetes_cluster_role" "oidc_proxy_role" {
  metadata {
    name = "kube-oidc-proxy-role"
  }

  rule {
    api_groups = [""]
    resources  = ["users", "groups", "serviceaccounts"]
    verbs      = ["impersonate"]
  }

  rule {
    api_groups = ["authentication.k8s.io"]
    resources  = ["userextras/scopes", "userextras/remote-client-ip", "tokenreviews", "userextras/originaluser.jetstack.io-user", "userextras/originaluser.jetstack.io-groups", "userextras/originaluser.jetstack.io-extra"]
    verbs      = ["create", "impersonate"]
  }

  rule {
    api_groups = ["authorization.k8s.io"]
    resources  = ["subjectaccessreviews"]
    verbs      = ["create"]
  }
}

resource "kubernetes_cluster_role_binding" "oidc_proxy_role_binding" {
  metadata {
    name = "kube-oidc-proxy-role-binding"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.oidc_proxy_role.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.kube_oidc_proxy_sa.metadata[0].name
    namespace = kubernetes_namespace.kube_oidc.metadata[0].name
  }
}

resource "kubernetes_service_v1" "oidc_proxy_service" {
  metadata {
    name        = "kube-oidc-proxy-service"
    namespace   = kubernetes_namespace.kube_oidc.metadata[0].name
    annotations = {
      "service.beta.kubernetes.io/azure-dns-label-name" = local.dns_label
    }
  }
  spec {
    type = "LoadBalancer"
    selector = {
      app = "kube-oidc"
    }
    port {
      name = "https"
      port = 443
      target_port = "https"
      protocol    = "TCP"
    }
  }
}
