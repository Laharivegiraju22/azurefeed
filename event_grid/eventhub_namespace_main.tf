#LOCALS BLOCK
locals {
  subnet = flatten([
    for k, v in var.eventhub_namespace_variables : [
      for i, j in v.eventhub_namespace_network_rulesets : [
        merge({
          main_key = k, nested_key = i
        }, j.network_rulesets_virtual_network_rule)
      ] if j.network_rulesets_virtual_network_rule != null
    ] if v.eventhub_namespace_network_rulesets != null
  ])
  identities_list = flatten([
    for k, v in var.eventhub_namespace_variables : [
      for i, j in v.eventhub_namespace_identity.eventhub_namespace_user_assigned_identities : [
        merge(
          {
            main_key                     = k
            identity_name                = j.user_assigned_identities_identity_name
            identity_resource_group_name = j.user_assigned_identities_identity_resource_group_name

          },
          j
        )
      ]
    ] if v.eventhub_namespace_identity.eventhub_namespace_user_assigned_identities != null

  ])
}

#DATA BLOCK TO EVENTHUB CLUSTER ID
data "azurerm_eventhub_cluster" "eventhub_cluster" {
  for_each            = { for k, v in var.eventhub_namespace_variables : k => v if lookup(v, "eventhub_namespace_dedicated_cluster_name", null) != null && lookup(v, "eventhub_namespace_eventhub_cluster_resource_group_name", null) != null }
  name                = each.value.eventhub_namespace_dedicated_eventhub_cluster_name
  resource_group_name = each.value.eventhub_namespace_eventhub_cluster_resource_group_name
}

#DATA BLOCK TO FETCH SUBNET ID
data "azurerm_subnet" "subnet" {
  for_each             = { for v in local.subnet : "${v.main_key},${v.nested_key}" => v }
  virtual_network_name = each.value.virtual_network_rule_subnet_virtual_network_name
  name                 = each.value.virtual_network_rule_subnet_name
  resource_group_name  = each.value.virtual_network_rule_subnet_resource_group_name
}

#DATA BLOCK TO FETCH USER ASSIGNED IDENTITY ID
data "azurerm_user_assigned_identity" "user_assigned_ids" {
  for_each            = { for v in local.identities_list : "${v.main_key},${v.identity_name}" => v }
  name                = each.value.user_assigned_identities_identity_name
  resource_group_name = each.value.user_assigned_identities_identity_resource_group_name
}

#EVENTHUB NAMESPACE
resource "azurerm_eventhub_namespace" "eventhub_namespace" {
  for_each                      = var.eventhub_namespace_variables
  name                          = each.value.eventhub_namespace_name
  location                      = each.value.eventhub_namespace_location
  resource_group_name           = each.value.eventhub_namespace_resource_group_name
  sku                           = each.value.eventhub_namespace_sku
  capacity                      = each.value.eventhub_namespace_capacity
  auto_inflate_enabled          = each.value.eventhub_namespace_auto_inflate_enabled
  dedicated_cluster_id          = each.value.eventhub_namespace_dedicated_eventhub_cluster_name == null ? null : data.azurerm_eventhub_cluster.eventhub_cluster[each.key].id
  maximum_throughput_units      = each.value.eventhub_namespace_maximum_throughput_units
  zone_redundant                = each.value.eventhub_namespace_zone_redundant
  local_authentication_enabled  = each.value.eventhub_namespace_local_authentication_enabled
  public_network_access_enabled = each.value.eventhub_namespace_public_network_access_enabled
  minimum_tls_version           = each.value.eventhub_namespace_minimum_tls_version
  tags                          = merge(each.value.eventhub_namespace_tags, tomap({ Created_Time = formatdate("DD-MM-YYYY hh:mm:ss ZZZ", timestamp()) }))
  lifecycle { ignore_changes = [tags["Created_Time"]] }
  dynamic "identity" {
    for_each = each.value.eventhub_namespace_identity != null ? [1] : []
    content {
      type = each.value.eventhub_namespace_identity.eventhub_namespace_identity_type
      identity_ids = each.value.eventhub_namespace_identity.eventhub_namespace_identity_type == "SystemAssigned, UserAssigned" || each.value.eventhub_namespace_identity.eventhub_namespace_identity_type == "UserAssigned" ? [
        for k, v in each.value.eventhub_namespace_identity.eventhub_namespace_user_assigned_identities : data.azurerm_user_assigned_identity.user_assigned_ids["${each.key},${v.user_assigned_identities_identity_name}"].id
      ] : null
    }
  }
  dynamic "network_rulesets" {
    for_each = each.value.eventhub_namespace_network_rulesets != null ? each.value.eventhub_namespace_network_rulesets : {}
    content {
      default_action                 = network_rulesets.value.network_rulesets_default_action
      trusted_service_access_enabled = network_rulesets.value.network_rulesets_trusted_service_access_enabled
      public_network_access_enabled  = network_rulesets.value.network_rulesets_public_network_access_enabled
      dynamic "virtual_network_rule" {
        for_each = network_rulesets.value.network_rulesets_virtual_network_rule == null ? [] : [network_rulesets.value.network_rulesets_virtual_network_rule]
        content {
          subnet_id                                       = data.azurerm_subnet.subnet["${each.key},${network_rulesets.key}"].id
          ignore_missing_virtual_network_service_endpoint = virtual_network_rule.value.virtual_network_rule_ignore_missing_virtual_network_service_endpoint
        }
      }
      dynamic "ip_rule" {
        for_each = network_rulesets.value.network_rulesets_ip_rule != null ? [network_rulesets.value.network_rulesets_ip_rule] : []
        content {
          ip_mask = ip_rule.value.ip_rule_ip_mask
          action  = ip_rule.value.ip_rule_action
        }
      }
    }
  }
}