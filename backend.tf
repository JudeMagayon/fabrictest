terraform {
  required_version = ">= 1.5.0"

  backend "azurerm" {
    resource_group_name  = "rg-nip-tfstate-eus"
    storage_account_name = "niptfstate"
    container_name       = "tfstate"
    key                  = "nip-fabric/default/terraform.tfstate"
    subscription_id      = "07621a69-8891-41c2-808e-e46b444bce0d"
    use_azuread_auth     = true
  }
}
