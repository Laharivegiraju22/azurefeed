#EVENTGRID SYSTEM TOPIC VARIABLES
variable "eventgrid_system_topic_variables" {
  type = map(object({
    eventgrid_system_topic_location                 = string #(Required) The Azure Region where the Event Grid System Topic should exist. Changing this forces a new Event Grid System Topic to be created.
    eventgrid_system_topic_name                     = string # (Required) The name which should be used for this Event Grid System Topic. Changing this forces a new Event Grid System Topic to be created.
    eventgrid_system_topic_resource_group_name      = string # (Required) The name of the Resource Group where the Event Grid System Topic should exist. Changing this forces a new Event Grid System Topic to be created.
    eventgrid_system_topic_source_arm_resource_name = string #(Required) Required if topic_type is not "Microsoft.Resources.Subscriptions" or "Microsoft.Resources.ResourceGroups". The name of the Source ARM to get The ID of the Event Grid System Topic ARM Source. Changing this forces a new Event Grid System Topic to be created.
    eventgrid_system_topic_topic_type               = string #(Required) The Topic Type of the Event Grid System Topic. The topic type is validated by Azure and there may be additional topic types beyond the following: Microsoft.AppConfiguration.ConfigurationStores, Microsoft.Communication.CommunicationServices, Microsoft.ContainerRegistry.Registries, Microsoft.Devices.IoTHubs, Microsoft.EventGrid.Domains, Microsoft.EventGrid.Topics, Microsoft.Eventhub.Namespaces, Microsoft.KeyVault.vaults, Microsoft.MachineLearningServices.Workspaces, Microsoft.Maps.Accounts, Microsoft.Media.MediaServices, Microsoft.Resources.ResourceGroups, Microsoft.Resources.Subscriptions, Microsoft.ServiceBus.Namespaces, Microsoft.SignalRService.SignalR, Microsoft.Storage.StorageAccounts, Microsoft.Web.ServerFarms and Microsoft.Web.Sites. Changing this forces a new Event Grid System Topic to be created.
    eventgrid_system_topic_identity = object({               #(Optional) An identity block
      identity_type = string                                 #(Required) Specifies the type of Managed Service Identity that should be configured on this Event Grid System Topic. Possible values are SystemAssigned, UserAssigned.
      identity_user_assigned_identities = list(object({      #(Optional) Specifies a list of User Assigned Managed Identity IDs to be assigned to this Event Grid System Topic.
        user_identity_name                = string           #(Optional)user assigned identity name Required if identity type "userassigned"
        user_identity_resource_group_name = string           #(Optional)resource group name of the user identity if identity type "userassigned"
      }))
    })
    eventgrid_system_topic_tags = map(string) # (Optional) A mapping of tags which should be assigned to the Event Grid System Topic.
  }))
  description = "Map of object of eventgrid system topic variables"
  default     = {}
}