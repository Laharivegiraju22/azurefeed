#EVENTGRID TOPIC VARIABLES
variable "eventgrid_topic_variables" {
  type = map(object({
    eventgrid_topic_name                                = string #(Required) Specifies the name of the EventGrid Topic resource. Changing this forces a new resource to be created.
    eventgrid_topic_resource_group_name                 = string #(Required) The name of the resource group in which the EventGrid Topic exists. Changing this forces a new resource to be created.
    eventgrid_topic_location                            = string #(Required) Specifies the supported Azure location where the resource exists. Changing this forces a new resource to be created.
    eventgrid_topic_input_schema                        = string #(Optional) Specifies the schema in which incoming events will be published to this domain. Allowed values are CloudEventSchemaV1_0, CustomEventSchema, or EventGridSchema. Defaults to EventGridSchema. Changing this forces a new resource to be created.
    eventgrid_topic_public_network_access_enabled       = bool   #(Optional) Whether local authentication methods is enabled for the EventGrid Topic. Defaults to true.
    eventgrid_topic_local_auth_enabled                  = bool   #(Optional) Whether local authentication methods is enabled for the EventGrid Topic. Defaults to true.
    eventgrid_topic_input_mapping_fields_is_id_required = bool   #(Optional) If mapping filed id is requried pass true, default false.
    eventgrid_topic_eventgrid_event_subscription_name   = string #(Optional) Event Grid Event Subscription Name. 
    eventgrid_topic_eventgrid_event_resource_group_name = string #(optional) Event Grid Event Resource Group Name.
    eventgrid_topic_identity = object({                          #(Optional) An identity block as defined below.
      identity_type = string                                     #(Required) Specifies the type of Managed Service Identity that should be configured on this Batch Account. Possible values are SystemAssigned, UserAssigned, SystemAssigned, UserAssigned (to enable both).
      user_assigned_identities = list(object({                   #(Optional) A list of User Assigned Managed Identity IDs to be assigned to this Batch Account.
        identity_name                = string                    #(Required) Identity name
        identity_resource_group_name = string                    #(Required) Identity resource group name
      }))
    })
    eventgrid_topic_inbound_ip_rule = list(object({ #block supports the following:
      inbound_ip_rule_ip_mask = string              #(Required) The IP mask (CIDR) to match on.
      inbound_ip_rule_action  = string              #(Optional) The action to take when the rule is matched. Possible values are Allow.
    }))
    eventgrid_topic_input_mapping_default_values = object({ #supports the following:
      input_mapping_default_values_event_type   = string    #(Optional) Specifies the default event type of the EventGrid Event to associate with the domain. Changing this forces a new resource to be created.
      input_mapping_default_values_data_version = string    #(Optional) Specifies the default data version of the EventGrid Event to associate with the domain. Changing this forces a new resource to be created.
      input_mapping_default_values_subject      = string    #(Optional) Specifies the default subject of the EventGrid Event to associate with the domain. Changing this forces a new resource to be created.
    })
    eventgrid_topic_input_mapping_fields = object({ #supports the following:
      input_mapping_fields_id           = string    #(Optional) Specifies the id of the EventGrid Event to associate with the domain. Changing this forces a new resource to be created.
      input_mapping_fields_topic        = string    #(Optional) Specifies the topic of the EventGrid Event to associate with the domain. Changing this forces a new resource to be created. 
      input_mapping_fields_event_type   = string    #(Optional) Specifies the event type of the EventGrid Event to associate with the domain. Changing this forces a new resource to be created.
      input_mapping_fields_data_version = string    #(Optional) Specifies the data version of the EventGrid Event to associate with the domain. Changing this forces a new resource to be created.
      input_mapping_fields_event_time   = string    #(Optional) Specifies the event time of the EventGrid Event to associate with the domain. Changing this forces a new resource to be created.
      input_mapping_fields_subject      = string    #(Optional) Specifies the subject of the EventGrid Event to associate with the domain. Changing this forces a new resource to be created.
    })
    eventgrid_topic_tags = map(string) #(Optional) A mapping of tags to assign to the resource.
  }))
  description = "Map of Eventgrid Topic"
  default     = {}
}