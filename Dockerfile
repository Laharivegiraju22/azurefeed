FROM python:3.12-alpine
WORKDIR /app

RUN apk add --no-cache curl build-base

COPY . .

# Accept build-time PAT
ARG AZURE_DEVOPS_PAT

RUN mkdir -p /root/.pip && \
    echo "[global]" > /root/.pip/pip.conf && \
    echo "index-url = https://${AZURE_DEVOPS_PAT}:@pkgs.dev.azure.com/SailahariVegiraju/_packaging/pypublicfeed/pypi/simple/" >> /root/.pip/pip.conf

RUN pip install --no-cache-dir -r requirements.txt
EXPOSE 8080
ENTRYPOINT ["python3", "app.py"]

locals {
  fqdn_rules = {
    for ws_key, ws in var.workspace_fqdns :
    # loop over fqdns inside each workspace
    # build a unique key for each rule
    for fqdn in ws.fqdns :
    "${ws_key}-${fqdn}" => {
      workspace_id = ws.workspace_id
      fqdn         = fqdn
    }
  }
}

resource "azurerm_machine_learning_workspace_network_outbound_rule_fqdn" "rules" {
  for_each = local.fqdn_rules

  name             = "rule-${replace(each.value.fqdn, ".", "-")}"
  workspace_id     = each.value.workspace_id
  destination_fqdn = each.value.fqdn
}

variable "workspace_fqdns" {
  type = map(object({
    workspace_id = string
    fqdns        = list(string)
  }))
}

workspace_fqdns = {
  "mlws1" = {
    workspace_id = "/subscriptions/xxx/resourceGroups/rg1/providers/Microsoft.MachineLearningServices/workspaces/mlws1"
    fqdns        = ["example.com", "api.example.com"]
  }

  "mlws2" = {
    workspace_id = "/subscriptions/xxx/resourceGroups/rg2/providers/Microsoft.MachineLearningServices/workspaces/mlws2"
    fqdns        = ["data.example.net", "model.example.net"]
  }
}