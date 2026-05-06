targetScope = 'resourceGroup'

@description('The location used for all deployed resources')
param location string = resourceGroup().location

@description('Tags that will be applied to all resources')
param tags object = {}

@description('Resource name for the app service')
param resourceName string

@description('Resource ID of the app service plan')
param appServicePlanId string

@description('Application Insights instrumentation key for monitoring')
param applicationInsightsInstrumentationKey string = ''

@description('Application Insights connection string for monitoring')
param applicationInsightsConnectionString string = ''

@description('The azd service name used to tag the App Service for azd deploy targeting')
param serviceName string = ''

// Create the App Service (Web App)
resource appService 'Microsoft.Web/sites@2023-12-01' = {
  name: resourceName
  location: location
  tags: union(tags, !empty(serviceName) ? { 'azd-service-name': serviceName } : {})
  kind: 'app,linux'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: appServicePlanId
    httpsOnly: true
    siteConfig: {
      alwaysOn: true
      linuxFxVersion: 'DOTNETCORE|8.0'
      appSettings: [
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: applicationInsightsConnectionString
        }
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: applicationInsightsInstrumentationKey
        }
        {
          name: 'ApplicationInsightsAgent_EXTENSION_VERSION'
          value: '~3'
        }
        {
          name: 'XDT_MicrosoftApplicationInsights_Mode'
          value: 'recommended'
        }
      ]
    }
  }
}

output appServiceId string = appService.id
output appServiceName string = appService.name
output appServiceDefaultHostName string = appService.properties.defaultHostName
output appServiceUri string = 'https://${appService.properties.defaultHostName}'
