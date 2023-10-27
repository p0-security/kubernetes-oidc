variable security_groups {
  type = set(string)
  description = "List of security groups that are assigned to the OIDC application in Azure. Only these groups will be present in the \"groups\" claim of the OIDC token, provided the authenticating user is also member of the group."
}