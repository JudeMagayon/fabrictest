output "existing_resource_group" {
  value = {
    id   = data.azurerm_resource_group.existing.id
    name = data.azurerm_resource_group.existing.name
  }
}

output "existing_fabric_capacity" {
  value = {
    id   = data.azurerm_fabric_capacity.existing.id
    name = data.azurerm_fabric_capacity.existing.name
  }
}

output "existing_workspaces" {
  value = {
    jobs      = { id = data.azurerm_fabric_workspace.jobs.id, name = data.azurerm_fabric_workspace.jobs.name }
    df        = { id = data.azurerm_fabric_workspace.df.id, name = data.azurerm_fabric_workspace.df.name }
    reporting = { id = data.azurerm_fabric_workspace.reporting.id, name = data.azurerm_fabric_workspace.reporting.name }
    ws1       = var.existing_ws1_workspace_name != "" ? { id = data.azurerm_fabric_workspace.ws1[0].id, name = data.azurerm_fabric_workspace.ws1[0].name } : null
  }
}

output "lakehouses" {
  value       = module.lakehouses.lakehouses
  description = "Medallion lakehouses created in the jobs workspace."
}

output "artifacts" {
  value = {
    dataflow  = module.artifacts.dataflow
    pipeline  = module.artifacts.pipeline
    notebook  = module.artifacts.notebook
  }
}
