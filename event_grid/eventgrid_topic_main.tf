locals {
  identities = { for k, v in var.eventgrid_topic_variables : k => lookup(v, "eventgrid_topic_identity", null) != null ? v.eventgrid_topic_identity.identity_type != "SystemAssigned" ? v.eventgrid_topic_identity.user_assigned_identities : null : null }
  identities_list = flatten([
    for k, v in local.identities : [for i in v : [
      {
        main_key                     = k
        identity_name                = i.identity_name
        identity_resource_group_name = i.identity_resource_group_name
    }]] if v != null
  ])
}

data "azurerm_client_config" "current" {
}

data "azurerm_user_assigned_identity" "user_assigned_ids" {
  for_each            = { for v in local.identities_list : "${v.main_key},${v.identity_name}" => v }
  name                = each.value.identity_name
  resource_group_name = each.value.identity_resource_group_name
}

resource "azurerm_eventgrid_topic" "eventgrid_topic" {
  for_each                      = var.eventgrid_topic_variables
  name                          = each.value.eventgrid_topic_name
  resource_group_name           = each.value.eventgrid_topic_resource_group_name
  location                      = each.value.eventgrid_topic_location
  input_schema                  = each.value.eventgrid_topic_input_schema
  public_network_access_enabled = each.value.eventgrid_topic_public_network_access_enabled
  local_auth_enabled            = each.value.eventgrid_topic_local_auth_enabled
  dynamic "identity" {
    for_each = each.value.eventgrid_topic_identity != null ? [1] : []
    content {
      type = each.value.eventgrid_topic_identity.identity_type
      identity_ids = each.value.eventgrid_topic_identity.identity_type == "SystemAssigned, UserAssigned" || each.value.eventgrid_topic_identity.identity_type == "UserAssigned" ? [
        for k, v in each.value.eventgrid_topic_identity.user_assigned_identities : data.azurerm_user_assigned_identity.user_assigned_ids["${each.key},${v.identity_name}"].id
      ] : null
    }
  }
  dynamic "inbound_ip_rule" {
    for_each = each.value.eventgrid_topic_inbound_ip_rule != null ? [1] : []
    content {
      ip_mask = each.value.eventgrid_topic_inbound_ip_rule.inbound_ip_rule_ip_mask
      action  = each.value.eventgrid_topic_inbound_ip_rule.inbound_ip_rule_action
    }
  }
  dynamic "input_mapping_default_values" {
    for_each = each.value.eventgrid_topic_input_mapping_default_values != null ? [1] : []
    content {
      event_type   = each.value.eventgrid_topic_input_mapping_default_values.input_mapping_default_values_event_type
      data_version = each.value.eventgrid_topic_input_mapping_default_values.input_mapping_default_values_data_version
      subject      = each.value.eventgrid_topic_input_mapping_default_values.input_mapping_default_values_subject
    }
  }
  dynamic "input_mapping_fields" {
    for_each = each.value.eventgrid_topic_input_mapping_fields != null ? [1] : []
    content {
      id           = each.value.eventgrid_topic_input_mapping_fields_is_id_required == true ? "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${each.value.eventgrid_topic_eventgrid_event_resource_group_name}/providers/Microsoft.EventGrid/topics/${each.value.eventgrid_topic_name}/providers/Microsoft.EventGrid/eventSubscriptions/${each.value.eventgrid_topic_eventgrid_event_subscription_name}" : null
      topic        = each.value.eventgrid_topic_input_mapping_fields.input_mapping_fields_topic
      event_type   = each.value.eventgrid_topic_input_mapping_fields.input_mapping_fields_event_type
      event_time   = each.value.eventgrid_topic_input_mapping_fields.input_mapping_fields_event_time
      data_version = each.value.eventgrid_topic_input_mapping_fields.input_mapping_fields_data_version
      subject      = each.value.eventgrid_topic_input_mapping_fields.input_mapping_fields_subject
    }
  }
  tags = merge(each.value.eventgrid_topic_tags, tomap({ Created_Time = formatdate("DD-MM-YYYY hh:mm:ss ZZZ", timestamp()) }))
  lifecycle { ignore_changes = [tags["Created_Time"]] }
}