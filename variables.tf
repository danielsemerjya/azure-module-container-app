variable "resource_group_name" {
  description = "The name of the resource group in which the container app will be created."
  type        = string
}

variable "container_app_name" {
  description = "The name of the container app environment."
  type        = string
}
variable "identity_ids" {
  description = "The identity ids to assign to the container app. (User assigned identity)"
  type        = list(string)
}


variable "containers" {
  description = "The container apps to create. Definition of each container in the container app environment."
  type = list(object({
    name                         = string
    external_connections_enabled = bool
    port_target                  = number
    # port_exposed                  = number
    container_name                = string
    container_registry_server     = string
    container_registry_repository = string
    container_cpu                 = number
    container_ram                 = string
    container_min_replicas        = number
    container_max_replicas        = number
    secrets = list(object({
      name  = string
      value = string
    }))
  }))
}

