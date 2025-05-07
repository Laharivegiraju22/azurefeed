#EVENTHUB NAMESPACE VARIABLES
variable "eventhub_namespace_variables" {
  type = map(object({
    eventhub_namespace_name                                 = string   # (Required) Specifies the name of the EventHub Namespace resource. Changing this forces a new resource to be created.
    eventhub_namespace_location                             = string   # (Required) Specifies the supported Azure location where the resource exists. Changing this forces a new resource to be created.
    eventhub_namespace_resource_group_name                  = string   # (Required) The name of the resource group in which to create the namespace. Changing this forces a new resource to be created.
    eventhub_namespace_sku                                  = string   # (Required) Defines which tier to use. Valid options are Basic, Standard, and Premium. Please note that setting this field to Premium will force the creation of a new resource.
    eventhub_namespace_capacity                             = number   # (Optional) Specifies the Capacity / Throughput Units for a Standard SKU namespace. Default capacity has a maximum of 2, but can be increased in blocks of 2 on a committed purchase basis.
    eventhub_namespace_auto_inflate_enabled                 = bool     # (Optional) Is Auto Inflate enabled for the EventHub Namespace?
    eventhub_namespace_maximum_throughput_units             = number   # (Optional) Specifies the maximum number of throughput units when Auto Inflate is Enabled. Valid values range from 1 - 20.
    eventhub_namespace_zone_redundant                       = string   # (Optional) Specifies if the EventHub Namespace should be Zone Redundant (created across Availability Zones). Changing this forces a new resource to be created. Defaults to false.
    eventhub_namespace_dedicated_eventhub_cluster_name      = string   # (Optional) Specifies the name of the EventHub Cluster resource. Required, when the namespace needs a dedicated eventhub_cluster
    eventhub_namespace_eventhub_cluster_resource_group_name = string   # (Optional) The name of the resource group in which the EventHub Cluster exists. Required, when the namespace needs a dedicated eventhub_cluster
    eventhub_namespace_local_authentication_enabled         = bool     # (Optional) Is SAS authentication enabled for the EventHub Namespace?
    eventhub_namespace_public_network_access_enabled        = bool     # (Optional) Is public network access enabled for the EventHub Namespace? Defaults to true.
    eventhub_namespace_minimum_tls_version                  = string   # (Optional) Specifies the maximum number of throughput units when Auto Inflate is Enabled. Valid values range from 1 - 20.
    eventhub_namespace_identity = object({                             # (Optional) An identity block
      eventhub_namespace_identity_type = string                        # (Required) Specifies the type of Managed Service Identity that should be configured on this Eventhub Namespace. Possible values are SystemAssigned, UserAssigned, SystemAssigned, UserAssigned (to enable both).
      eventhub_namespace_user_assigned_identities = list(object({      # (Optional) Specifies a list of User Assigned Managed Identity IDs to be assigned to this Eventhub Namespace.
        user_assigned_identities_identity_name                = string # (Optional) Specifies  User Assigned Managed Identity name
        user_assigned_identities_identity_resource_group_name = string # (Optional) Specifies  User Assigned Managed Identity resource group name
      }))
    })
    eventhub_namespace_network_rulesets = map(object({                                # (Optional) A network_rulesets block as defined below.
      network_rulesets_default_action                 = string                        # (Required) The default action to take when a rule is not matched. Possible values are Allow and Deny.
      network_rulesets_trusted_service_access_enabled = bool                          # (Optional) Whether Trusted Microsoft Services are allowed to bypass firewall.
      network_rulesets_public_network_access_enabled  = bool                          # (Optional) Is public network access enabled for the EventHub Namespace? Defaults to true.
      network_rulesets_virtual_network_rule = object({                                # (Optional) One or more virtual_network_rule blocks as defined below.
        virtual_network_rule_subnet_name                                     = string # (Required) The name of the subnet. Changing this forces a new resource to be created.
        virtual_network_rule_subnet_resource_group_name                      = string # (Required) The name of the resource group in which to create the subnet. Changing this forces a new resource to be created.
        virtual_network_rule_subnet_virtual_network_name                     = string # (Required) The name of the virtual network to which to attach the subnet. Changing this forces a new resource to be created.
        virtual_network_rule_ignore_missing_virtual_network_service_endpoint = bool   # (Optional) Are missing virtual network service endpoints ignored? Defaults to false.
      })
      network_rulesets_ip_rule = object({ #(Optional) One or more ip_rule blocks as defined below.
        ip_rule_ip_mask = string          #(Required) The IP mask to match on.
        ip_rule_action  = string          #(Optional) The action to take when the rule is matched. Possible values are Allow.
      })
    }))
    eventhub_namespace_tags = map(string) # (Optional) A mapping of tags to assign to the resource.
  }))
  description = "Map of EventHub Namespace Variables"
  default     = {}
}