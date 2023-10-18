data "azuread_group" "devs" {
  display_name     = var.security_group_display_name
  security_enabled = true
}

resource "azuread_app_role_assignment" "app_group_assignment" {
  # Assign to the default role
  app_role_id         = "00000000-0000-0000-0000-000000000000"
  principal_object_id = data.azuread_group.devs.object_id
  resource_object_id  = var.app_object_id
}
