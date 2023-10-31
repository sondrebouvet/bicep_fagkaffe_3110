
targetScope = 'subscription'


@description('Azure region')
param location string  = 'norwayeast'

@minLength(3)
@maxLength(20)
@description('Name of resource group 1 ')
param resourceGroupName1 string 


@minLength(3)
@maxLength(20)
@description('Name of resource group 2')
param resourceGroupName2 string

@minLength(3)
@maxLength(24)
@description('Storage account in resource group 1')
param storageAccountName1 string = '${resourceGroupName1}sa'


@minLength(3)
@maxLength(24)
@description('Storage account in resource group 2')
param storageAccountName2 string = '${resourceGroupName2}sa'

@description('Name of keyvault resource')
param keyvaultName string

@description('Name of data factory resource')
param datafactoryName string

resource newResourceGroup1 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: resourceGroupName1
  location: location
  properties: {}
}



resource newResourceGroup2 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: resourceGroupName2
  location: location
  properties: {}
}


module keyVaultModule 'keyvault.bicep' = {
  scope : newResourceGroup1

  name: 'keyvault'
  params: {
    location: location
    keyVaultName: keyvaultName
    keyVaultPrincipalId: []
    keyVaultPermissions:  {
      keys: [
        'all'
      ]
      secrets: [
        'all'
      ]
    }
  }
}


module datafactoryModule 'datafactory.bicep' = {
  name: 'dataFactoryModule'
  scope: newResourceGroup1
  params: {
    principalIds: []
    managedVnetName: '${datafactoryName}Vnet'
    integrationRunTimeName: '${datafactoryName}Runtime'
    dataFactoryName: datafactoryName
    location: location
  }
}


@description('Storage module for resource group 1')
module storage1 'storage/storageModule.bicep' = {
    name: '${storageAccountName1}deploy'
    scope : newResourceGroup1
    params: {
      createContainers: false
      allowTrustedAzureResources: true
      location: location
      principalIdArray: []
      resourceTags: {}
      roleDefinitionsArray: []
      keyVaultName: keyvaultName
      storageAccountName: storageAccountName1
      storageContainers: ['c1', 'c2', 'c3']
      storageFireWallRules: []
      storageKind: 'StorageV2'
      virtualNetworkIds: []

    }
    dependsOn: [keyVaultModule]
    
} 


@description('Storage module for resource group 2')
module storage2 'storage/storageModule.bicep' = {
    name: '${storageAccountName2}deploy'
    scope : newResourceGroup2
    params: {
      createContainers: false
      allowTrustedAzureResources: true
      location: location
      principalIdArray: []
      resourceTags: {}
      roleDefinitionsArray: []
      keyVaultName: keyvaultName
      storageAccountName: storageAccountName2
      storageContainers: []
      storageFireWallRules: []
      storageKind: 'StorageV2'
      virtualNetworkIds: []


    }
    dependsOn: [
      keyVaultModule
    ]
  
} 
