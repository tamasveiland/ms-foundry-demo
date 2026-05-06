targetScope = 'resourceGroup'

@description('The location used for all deployed resources')
param location string = resourceGroup().location

@description('Tags that will be applied to all resources')
param tags object = {}

@description('Resource name for the API Management instance')
param resourceName string

@description('The publisher name for the API Management instance')
param publisherName string = 'API Administrator'

@description('The publisher email for the API Management instance')
param publisherEmail string = 'admin@example.com'

@description('The pricing tier of the API Management instance')
@allowed([
  'Consumption'
  'Developer'
  'Basic'
  'Standard'
  'Premium'
])
param skuName string = 'Consumption'

@description('The number of instances for non-Consumption SKU')
param skuCount int = 1

// Create the API Management instance
resource apiManagement 'Microsoft.ApiManagement/service@2023-09-01-preview' = {
  name: resourceName
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    publisherEmail: publisherEmail
    publisherName: publisherName
  }
  sku: {
    name: skuName
    capacity: skuName == 'Consumption' ? 0 : skuCount
  }
}

output apiManagementId string = apiManagement.id
output apiManagementName string = apiManagement.name
output apiManagementGatewayUrl string = apiManagement.properties.gatewayUrl
output apiManagementDeveloperPortalUrl string = apiManagement.properties.developerPortalUrl
output apiManagementManagementApiUrl string = apiManagement.properties.managementApiUrl
output apiManagementScmUrl string = apiManagement.properties.scmUrl
