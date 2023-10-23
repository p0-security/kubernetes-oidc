output "root_ca_certificate" {
  value = "${tls_self_signed_cert.kube_oidc_ca_cert.cert_pem}"
}