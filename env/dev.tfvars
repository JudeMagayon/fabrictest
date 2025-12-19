client          = "nipgroup"
environment     = "dev"
location        = "eastus"
subscription_id = "e653ba88-fc91-42f4-b22b-c35e36b00835"

existing_resource_group_name     = "rg-nip-fab-dev-eus"
existing_capacity_name           = "fc-nip-fabric-dev-eus"
existing_jobs_workspace_name      = "ws-nip-jobs-dev"
existing_df_workspace_name        = "ws-nip-df-dev"
existing_reporting_workspace_name = "ws-nip-reporting-dev"
existing_ws1_workspace_name       = "ws-nip-ws1-dev"

tags = {
  environment = "dev"
  owner       = "data-team"
}

administrator_upns = []

artifacts_dataflow_usage  = "ingestion"
artifacts_pipeline_usage  = "orchestration"
artifacts_notebook_usage  = "preparation"
enable_schemas            = true
