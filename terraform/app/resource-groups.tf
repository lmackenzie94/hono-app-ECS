# --------------------------------------
# AWS Resource Group configuration
# Creates a resource group containing all resources with the tag "Application=hono-app-ecs".
# --------------------------------------
resource "aws_resourcegroups_group" "hono_app_ecs" {
  name = var.app_name

  resource_query {
    query = jsonencode({
      ResourceTypeFilters = ["AWS::AllSupported"]
      TagFilters = [
        {
          Key    = "Application"
          Values = [var.app_name]
        }
      ]
    })
    type = "TAG_FILTERS_1_0" # this is the default type
  }
}