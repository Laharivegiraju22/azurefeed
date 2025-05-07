locals {
  identities_list = flatten([for k, v in var.eventgrid_system_topic_variables :
    [for l, i in v.eventgrid_system_topic_identity.identity_user_assigned_identities : {
      main_key           = k,
      user_identity_name = i.user_identity_name,
      user_identity_resource_group_name = i.user_identity_resource_group_name }
    ]
  if lookup(v, "eventgrid_system_topic_identity", null) != null ? lookup(v.eventgrid_system_topic_identity, "identity_type", "SystemAssigned") != "SystemAssigned" : false])
}

data "azurerm_subscription" "current" {
  provider = azurerm.eventgrid_system_topic_sub
}

data "azurerm_resource_group" "resource_group" {
  provider = azurerm.eventgrid_system_topic_sub
  for_each = var.eventgrid_system_topic_variables
  name     = each.value.eventgrid_system_topic_resource_group_name
}

data "azurerm_resources" "resources_source" {
  provider = azurerm.eventgrid_system_topic_sub
  for_each = { for k, v in var.eventgrid_system_topic_variables : k => v if v.eventgrid_system_topic_source_arm_resource_name != null }
  name     = each.value.eventgrid_system_topic_source_arm_resource_name
}

data "azurerm_user_assigned_identity" "user_assigned_identity" {
  provider            = azurerm.user_assigned_identity_sub
  for_each            = { for v in local.identities_list : "${v.main_key},${v.user_identity_name}" => v }
  name                = each.value.user_identity_name
  resource_group_name = each.value.user_identity_resource_group_name
}

resource "azurerm_eventgrid_system_topic" "eventgrid_system_topic" {
  provider               = azurerm.eventgrid_system_topic_sub
  for_each               = var.eventgrid_system_topic_variables
  location               = each.value.eventgrid_system_topic_location
  name                   = each.value.eventgrid_system_topic_name
  resource_group_name    = each.value.eventgrid_system_topic_resource_group_name
  source_arm_resource_id = each.value.eventgrid_system_topic_topic_type == "Microsoft.Resources.Subscriptions" ? data.azurerm_subscription.current.id : each.value.eventgrid_system_topic_topic_type == "Microsoft.Resources.ResourceGroups" ? data.azurerm_resource_group.resource_group[each.key].id : data.azurerm_resources.resources_source[each.key].resources[0].id
  topic_type             = each.value.eventgrid_system_topic_topic_type
  dynamic "identity" {
    for_each = each.value.eventgrid_system_topic_identity != null ? [each.value.eventgrid_system_topic_identity] : []
    content {
      type = identity.value.identity_type
      identity_ids = identity.value.identity_type == "UserAssigned" ? [
        for k, v in identity.value.identity_user_assigned_identities : data.azurerm_user_assigned_identity.user_assigned_identity["${each.key},${v.user_identity_name}"].id
      ] : null
    }
  }
  tags = merge(each.value.eventgrid_system_topic_tags, tomap({ Created_Time = formatdate("DD-MM-YYYY hh:mm:ss ZZZ", timestamp()) }))
  lifecycle { ignore_changes = [tags["Created_Time"]] }
}