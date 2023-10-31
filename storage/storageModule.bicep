/*
* Module for initaliasing storage-related resources
*/

@description('Role defintions to apply to principals')
param roleDefinitionsArray array

@description('PrincipalIds of resources for which to apply role definitions')
param principalIdArray array

@maxLength(24)
@minLength(3)
@description('Name of storage account')
param storageAccountName string

@description('Resource tag object')
param resourceTags object

@description('Location of resources to be deployed')
param location string

@description('Boolean dicates whether containers should be created')
param createContainers bool

@description('Name of storage containers')
param storageContainers array

@description('Storage kind, e.g StorageV2')
param storageKind string

@description('ID of virtual network rules, for example id of the Databricks public subnet ')
param virtualNetworkIds array

@description('Fire wall rules of storage account')
param storageFireWallRules array

@description('Allow trusted azure resources')
param allowTrustedAzureResources bool


@description('Name of key vault')
param keyVaultName string


module storage 'storage.bicep' = {
  name: storageAccountName
  params: {
    tagArray: resourceTags
    storageName: storageAccountName
    createContainers: createContainers
    location: location
    storageKind: storageKind
    allowTrustedAzureResources: allowTrustedAzureResources
    storageFireWallRulesInput: storageFireWallRules
    virtualNetworkIds: virtualNetworkIds
    storageContainers: storageContainers

  }
}

module storageSecret 'storageSecret.bicep' = {
  name: '${storageAccountName}secrets'
  params: {
    storageAccountId: storage.outputs.storageAccountId
    keyVaultName: keyVaultName
    storageAccountName: storageAccountName
  }
  dependsOn: [
    storage
  ]
}

module roleAssignmentStorage 'storageRoleAssignment.bicep' = [for roleDefintion in roleDefinitionsArray: if (!empty(roleDefintion)) {
  name: 'roleAssignment${storageAccountName}${take(guid(roleDefintion), 14)}'
  params: {
    roleDefinition: roleDefintion
    storageAccountName: storageAccountName
    principalIdArray: principalIdArray
  }
  dependsOn: [ storage ]

}]

output storageAccountId string = storage.outputs.storageAccountId
