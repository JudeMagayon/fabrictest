data "azurerm_resource_group" "existing" {
  name = var.existing_resource_group_name
}

data "azurerm_fabric_capacity" "existing" {
  name                = var.existing_capacity_name
  resource_group_name = data.azurerm_resource_group.existing.name
}

data "azurerm_fabric_workspace" "jobs" {
  name                = var.existing_jobs_workspace_name
  resource_group_name = data.azurerm_resource_group.existing.name
}# -----------------------------------------------------------------------------
# Discover current Azure client configuration
# -----------------------------------------------------------------------------
data "azurerm_client_config" "current" {}

# -----------------------------------------------------------------------------
# Reference EXISTING Option 1 resources (NO creation)
# -----------------------------------------------------------------------------
data "azurerm_resource_group" "existing" {
  name = var.existing_resource_group_name
}

data "azurerm_fabric_capacity" "existing" {
  name                = var.existing_capacity_name
  resource_group_name = data.azurerm_resource_group.existing.name
}

data "azurerm_fabric_workspace" "jobs" {
  name                = var.existing_jobs_workspace_name
  resource_group_name = data.azurerm_resource_group.existing.name
}

data "azurerm_fabric_workspace" "df" {
  name                = var.existing_df_workspace_name
  resource_group_name = data.azurerm_resource_group.existing.name
}

data "azurerm_fabric_workspace" "reporting" {
  name                = var.existing_reporting_workspace_name
  resource_group_name = data.azurerm_resource_group.existing.name
}

data "azurerm_fabric_workspace" "ws1" {
  count               = var.existing_ws1_workspace_name != "" ? 1 : 0
  name                = var.existing_ws1_workspace_name
  resource_group_name = data.azurerm_resource_group.existing.name
}

# -----------------------------------------------------------------------------
# Guardrails (fail fast if mismatched env naming)
# -----------------------------------------------------------------------------
resource "null_resource" "validate_option1" {
  lifecycle {
    precondition {
      condition     = endswith(lower(var.existing_capacity_name), "-${lower(var.environment)}-eus")
      error_message = "existing_capacity_name must end with -<environment>-eus (Option 1)."
    }
    precondition {
      condition     = endswith(lower(var.existing_jobs_workspace_name), "-${lower(var.environment)}")
      error_message = "existing_jobs_workspace_name must end with -<environment> (Option 1)."
    }
    precondition {
      condition     = endswith(lower(var.existing_df_workspace_name), "-${lower(var.environment)}")
      error_message = "existing_df_workspace_name must end with -<environment> (Option 1)."
    }
    precondition {
      condition     = endswith(lower(var.existing_reporting_workspace_name), "-${lower(var.environment)}")
      error_message = "existing_reporting_workspace_name must end with -<environment> (Option 1)."
    }
  }
}

# -----------------------------------------------------------------------------
# Create Lakehouses in the EXISTING JOBS workspace (Option 1)
# Pattern: lh_<layer>_<workspace_name>
# -----------------------------------------------------------------------------
module "lakehouses" {
  source         = "../../modules/lakehouses"
  workspace_id   = data.azurerm_fabric_workspace.jobs.id
  workspace_name = var.existing_jobs_workspace_name
  layers         = ["bronze", "silver", "gold"]
  name_prefix    = "lh"
  enable_schemas = var.enable_schemas
}

# -----------------------------------------------------------------------------
# Create core artifacts in the EXISTING JOBS workspace (Option 1)
# Naming pattern: <service>_<usage>_<workspace_name>
# -----------------------------------------------------------------------------
module "artifacts" {
  source         = "../../modules/artifacts"
  workspace_id   = data.azurerm_fabric_workspace.jobs.id
  workspace_name = var.existing_jobs_workspace_name
  dataflow_usage = var.artifacts_dataflow_usage
  pipeline_usage = var.artifacts_pipeline_usage
  notebook_usage = var.artifacts_notebook_usage
}

# -----------------------------------------------------------------------------
# Azure RBAC - Resolve Azure AD users and assign roles (guarded)
# -----------------------------------------------------------------------------
data "azuread_user" "admins" {
  for_each            = toset(var.administrator_upns)
  user_principal_name = each.value
}

# Assign Contributor on the Fabric Capacity to administrators (prevent accidental removal)
resource "azurerm_role_assignment" "capacity_admins" {
  for_each             = data.azuread_user.admins
  scope                = data.azurerm_fabric_capacity.existing.id
  role_definition_name = "Contributor"
  principal_id         = each.value.object_id

  lifecycle {
    prevent_destroy = true
  }
}

# Assign Contributor on the Resource Group to administrators (prevent accidental removal)
resource "azurerm_role_assignment" "rg_admins" {
  for_each             = data.azuread_user.admins
  scope                = data.azurerm_resource_group.existing.id
  role_definition_name = "Contributor"
  principal_id         = each.value.object_id

  lifecycle {
    prevent_destroy = true
  }
}
