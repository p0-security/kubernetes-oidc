Enable the identity service in Terraform, which is basically the following block added to your `google_container_cluster` resource:
```
  identity_service_config {
    enabled = true
  }
```

The identity service in Kubernetes then must be patched to configure your IdP.
Use the `scripts/configure.sh` script, and pass the OIDC parameters as environment variables. 
Make sure to execute the script from a kube context that can update ClientConfig and Service objects.

Example (Microsoft Entra ID):
```
issuer=https://login.microsoftonline.com/83433720-5d86-45f8-b81f-a92a047d85ea/v2.0 client_id={client_id} user_claim=preferred_username groups_claim=groups prefix="azure:" ./scripts/configure.sh
```
