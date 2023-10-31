@description('Array of principals to be given storage contributor access')
param principalIdArray  array 


@description('Role definition id to grant to principals. e.g, storage blob  contributor /providers/Microsoft.Authorization/roleDefinitions/ba92f5b4-2d11-453d-a403-e96b0029c9fe')
param roleDefinition string 

@description('Storage account name')
param storageAccountName string 



resource existingStorage 'Microsoft.Storage/storageAccounts@2022-05-01'  existing = {
  name : storageAccountName
}


@description('Role assignment for storage account')
resource roleAssignment 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = [for principalId in principalIdArray:  {
  name: guid(existingStorage.name, roleDefinition, principalId)
  scope: existingStorage
  properties: {
    principalId: principalId
    roleDefinitionId: roleDefinition
  }
}]


