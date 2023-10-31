/*
* Storage resource initialisation
*/


@minLength(3)
@maxLength(24)
@description('Provide a name for the storage account. Use only lower case letters and numbers. The name must be unique across Azure.')
param storageName string

@description('Location for the resource, gets this vaule from resource group')
param location string

@description('Boolean on whether or not to create containers for the storage account')
param createContainers bool

@description('Tags for the resource')
param tagArray object

@description('Input array of storage containers')
param storageContainers array 

@description('Enable or disable Blob encryption at Rest.')
param encryptionEnabled bool = true

@description('Allow trusted azure resources ')
param allowTrustedAzureResources bool

@description('Firewall rules')
param storageFireWallRulesInput array

//param storageFireWallRules array = (allowTrustedAzureResources) ? concat(storageFireWallRulesInput, ['127.0.0.1']) : storageFireWallRulesInput


param storageFireWallRules array = (allowTrustedAzureResources) ? storageFireWallRulesInput : storageFireWallRulesInput


@description('ID of virtual network rules, for example id of the Databricks public subnet ')
param virtualNetworkIds array

@description('Storage kind, e.g StorageV2')
param storageKind string


resource storageAccount 'Microsoft.Storage/storageAccounts@2022-05-01' = {
  name: storageName
  identity: {
    type: 'SystemAssigned'
  }
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  properties: {
    accessTier: (storageKind == 'Storage' ? null: 'Hot')
    allowedCopyScope: 'AAD'
    supportsHttpsTrafficOnly: true
    isHnsEnabled: (storageKind == 'Storage' ? null: true) 
    minimumTlsVersion: 'TLS1_2'
    networkAcls: {
      bypass: 'AzureServices'
      virtualNetworkRules: [for id in virtualNetworkIds: {
          id: id.id
          action: 'Allow'
          state: 'Succeeded'
        }]
      ipRules: [for rule in storageFireWallRules :  {
        action: 'Allow'
        value: '${rule.ip}'
      }]
      defaultAction: empty(storageFireWallRules) ? 'Allow': 'Deny'
    }
    encryption: {
      keySource: 'Microsoft.Storage'
      services: {
        blob: {
          enabled: encryptionEnabled
        }
      }
    }
  }
  kind: storageKind
  tags: tagArray

}




resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2022-09-01' = {
  parent: storageAccount
  name: 'default'
}


resource containers 'Microsoft.Storage/storageAccounts/blobServices/containers@2022-05-01' = [for nameContainer in storageContainers: if (createContainers) {
  parent: blobService
  name: nameContainer
}]


output storageAccountId string = storageAccount.id
