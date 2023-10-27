variable "oauth_app_name" {
  type = string
  default = "k8s OIDC demo app"
}

variable "auth_server_name" {
  type = string
  default = "k8s OIDC demo auth server"
}

variable "group_regex_filter" {
  type = string
  description = "Only groups matching the regex are returned in the id_token. Use it to control which groups are eligible for Kubernetes access."
  default = ".*"
}