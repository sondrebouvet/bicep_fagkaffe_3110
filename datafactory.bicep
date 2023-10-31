@description('Name for the datafactory')
param dataFactoryName string

@description('Location for the resource, gets this vaule from resource group')
param location string


param integrationRunTimeName string

@description('Name of data factory managed virutal network')
param managedVnetName string

@description('Array of principalDs needed for roleassignments')
param principalIds array

@description('Data factory contributor role')
param dataFactoryContributorRole string = '/providers/Microsoft.Authorization/roleDefinitions/673868aa-7521-48a0-acc6-0f60742d39f5'

resource dataFactory 'Microsoft.DataFactory/factories@2018-06-01' = {
  name: dataFactoryName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    publicNetworkAccess: 'Disabled'
  }

}

resource managedVnet 'Microsoft.DataFactory/factories/managedVirtualNetworks@2018-06-01' = {
  name: managedVnetName
  parent: dataFactory
  properties: {

  }
}

resource managedIntegrationRuntime 'Microsoft.DataFactory/factories/integrationRuntimes@2018-06-01' = {
  name: integrationRunTimeName
  parent: dataFactory
  properties: {
    type: 'Managed'
    managedVirtualNetwork: {
      referenceName: managedVnetName
      type: 'ManagedVirtualNetworkReference'
    }
    typeProperties: {
      computeProperties: {
        location: 'AutoResolve'
        dataFlowProperties: {
          computeType: 'General'
          coreCount: 4
          timeToLive: 0
        }
      }
    }
  }
  dependsOn: [ managedVnet ]
}

@description('Data factory contributor roles')
resource dataFactoryRoleAssignment 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = [for principalID in principalIds: {
  name: guid(dataFactory.id, resourceGroup().id, principalID)
  scope: dataFactory
  properties: {
    principalId: principalID
    roleDefinitionId: dataFactoryContributorRole
  }
}]

output principalId string = dataFactory.identity.principalId
