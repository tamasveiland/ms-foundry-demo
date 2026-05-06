targetScope = 'resourceGroup'

@description('The location used for all deployed resources')
param location string = resourceGroup().location

@description('Tags that will be applied to all resources')
param tags object = {}

@description('Resource name for the app service plan')
param resourceName string

@description('The pricing tier of the app service plan')
@allowed([
  'B1'
  'B2'
  'B3'
  'S1'
  'S2'
  'S3'
  'P1V2'
  'P2V2'
  'P3V2'
])
param skuName string = 'B1'

@description('The number of instances of the app service plan')
param capacity int = 1

// Create the App Service Plan
resource appServicePlan 'Microsoft.Web/serverfarms@2023-12-01' = {
  name: resourceName
  location: location
  tags: tags
  kind: 'linux'
  properties: {
    reserved: true
  }
  sku: {
    name: skuName
    capacity: capacity
  }
}

output appServicePlanId string = appServicePlan.id
output appServicePlanName string = appServicePlan.name
