data "azurerm_subscription" "main" {
}

output "environment" {
  value = var.environment
}

## https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subscription
output "azurerm_subscription_name" {
  value = data.azurerm_subscription.main.display_name
}

output "hostname" {
  value = var.hostname
}

# ref: https://github.com/Azure/terraform-azurerm-compute/blob/master/outputs.tf
output "public_ip_id" {
  description = "id of the public ip address provisoned."
  value       = azurerm_public_ip.main.*.id
}

output "admin_username" {
  value = var.admin_username
}

output "ssh_pub_key_path" {
  value = var.ssh_pub_key_path
}

output "azurerm_storage_account_name" {
  value = azurerm_storage_account.main.name
}


