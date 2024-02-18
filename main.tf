data "azurerm_resource_group" "this" {
  name = var.resource_group_name
}

resource "azurerm_log_analytics_workspace" "this" {
  name                = "law-${var.container_app_name}"
  location            = data.azurerm_resource_group.this.location
  resource_group_name = data.azurerm_resource_group.this.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_container_app_environment" "this" {
  name                       = "cae-${var.container_app_name}"
  location                   = data.azurerm_resource_group.this.location
  resource_group_name        = data.azurerm_resource_group.this.name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.this.id
}

resource "azurerm_container_app" "this" {
  for_each                     = { for container in var.containers : container.name => container }
  name                         = each.key
  container_app_environment_id = azurerm_container_app_environment.this.id
  resource_group_name          = data.azurerm_resource_group.this.name
  revision_mode                = "Single"

  ingress {
    allow_insecure_connections = false
    external_enabled           = each.value.external_connections_enabled #This is required to expose the container app to the internet
    target_port                = each.value.port_target
    # exposed_port               = each.value.port_exposed
    # transport                  = "tcp"
    traffic_weight {
      percentage      = 100
      latest_revision = true
    }

  }

  identity {
    type         = "UserAssigned"
    identity_ids = var.identity_ids
  }


  registry {
    server   = each.value.container_registry_server
    identity = var.identity_ids[0]
  }

  template {
    container {
      name  = each.value.container_name
      image = "${each.value.container_registry_server}/${each.value.container_registry_repository}"
      cpu   = each.value.container_cpu
      # (Required) The amount of vCPU to allocate to the container. Possible values include 0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 1.75, and 2.0.
      memory = "${each.value.container_ram}Gi"
      # 0.5Gi, 1Gi, 1.5Gi, 2Gi, 2.5Gi, 3Gi, 3.5Gi and 4Gi.
      dynamic "env" {
        for_each = each.value.secrets
        content {
          name        = env.value.name
          secret_name = env.value.name
        }
      }

    }

    max_replicas = each.value.container_max_replicas
    min_replicas = each.value.container_min_replicas
  }

  dynamic "secret" {
    for_each = each.value.secrets
    content {
      name  = secret.value.name
      value = secret.value.value
    }
  }

}
