############################################################
# Root module variable definitions
############################################################

variable "client" {
  description = "Client or tenant identifier used as the naming prefix (lowercase letters, numbers, hyphens)."
  type        = string
  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.client))
    error_message = "client must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "environment" {
  description = "Deployment environment suffix (dev, test, staging, prod)."
  type        = string
  validation {
    condition     = contains(["dev", "test", "staging", "prod"], lower(var.environment))
    error_message = "environment must be one of: dev, test, staging, prod."
  }
}

variable "location" {
  description = "Azure region."
  type        = string
  default     = "eastus"
}

variable "subscription_id" {
  description = "Azure subscription ID used by providers."
  type        = string
}

# -----------------------------
# Option 1 - EXISTING resources
# -----------------------------
variable "existing_resource_group_name" {
  description = "Existing Azure Resource Group name containing the Fabric capacity + workspaces."
  type        = string
}

variable "existing_capacity_name" {
  description = "Existing Fabric Capacity name (Option 1 naming, e.g. fc-nip-fabric-dev-eus)."
  type        = string
}

variable "existing_jobs_workspace_name" {
  description = "Existing Jobs workspace name (Option 1 naming, e.g. ws-nip-jobs-dev)."
  type        = string
}

variable "existing_df_workspace_name" {
  description = "Existing DataFactory/DF workspace name (Option 1 naming, e.g. ws-nip-df-dev)."
  type        = string
}

variable "existing_reporting_workspace_name" {
  description = "Existing Reporting workspace name (Option 1 naming, e.g. ws-nip-reporting-dev)."
  type        = string
}

# Optional (only exists in your diagram for Dev): ws-nip-ws1-dev
variable "existing_ws1_workspace_name" {
  description = "Optional existing workspace name (e.g. ws-nip-ws1-dev). Set to empty string if not used."
  type        = string
  default     = ""
}

# -----------------------------
# Tags / Feature flags
# -----------------------------
variable "tags" {
  type        = map(string)
  default     = {}
  description = "Common tags."
}

variable "enable_schemas" {
  description = "Whether to enable schemas feature on each lakehouse."
  type        = bool
  default     = true
}

# -----------------------------
# Artifacts naming usage tokens
# -----------------------------
variable "artifacts_dataflow_usage" {
  description = "Usage token for Dataflow name (pattern: dataflow_<usage>_<workspace_name>)."
  type        = string
  default     = "ingestion"
}

variable "artifacts_pipeline_usage" {
  description = "Usage token for Data Pipeline name (pattern: data_pipeline_<usage>_<workspace_name>)."
  type        = string
  default     = "orchestration"
}

variable "artifacts_notebook_usage" {
  description = "Usage token for Notebook name (pattern: notebook_<usage>_<workspace_name>)."
  type        = string
  default     = "preparation"
}

# -----------------------------
# Access / RBAC
# -----------------------------
variable "administrator_upns" {
  description = "List of administrator User Principal Names (emails)"
  type        = list(string)
  default     = []
}

variable "workspace_group_assignments" {
  description = "List of AAD group role assignments across Fabric workspaces."
  type = list(object({
    group_object_id    = optional(string)
    group_display_name = optional(string)
    role               = string
    workspaces         = optional(list(string), [])
  }))
  default = []
}

variable "pipeline_role_assignments" {
  description = "List of AAD role assignments for the deployment pipeline."
  type = list(object({
    role                = string
    principal_type      = string
    group_object_id     = optional(string)
    group_display_name  = optional(string)
    user_object_id      = optional(string)
    user_principal_name = optional(string)
  }))
  default = []
  validation {
    condition     = alltrue([for a in var.pipeline_role_assignments : lower(a.role) == "admin"])
    error_message = "deployment pipeline role assignments must use role 'Admin' only."
  }
}
