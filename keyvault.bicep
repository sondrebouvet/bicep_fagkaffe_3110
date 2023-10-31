@description('Name for the key vault')
param keyVaultName string

@description('Location for the resource, gets this vaule from resource group')
param location string


@description('Principal Id of the Azure resource (Managed Identity).')
param keyVaultPrincipalId array

@description('Assigned permissions for Principal Id (Managed Identity)')
param keyVaultPermissions object


@description('Key Vault Crypto Officer role')
param keyvaultOfficerRoleDefinition string = '/providers/Microsoft.Authorization/roleDefinitions/14b46e9e-c2b7-41b4-b07b-48a6ebf60603'

resource keyvault 'Microsoft.KeyVault/vaults@2022-07-01' = {
  name: keyVaultName

  location: location
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    enableSoftDelete: true
    enableRbacAuthorization: false
    tenantId: subscription().tenantId
    accessPolicies: [for id in keyVaultPrincipalId: {
      objectId: id
      permissions: keyVaultPermissions
      tenantId: subscription().tenantId
    }]

  }


}

@description('Role assignment for keyvault ')
resource roleAuthorizationKeyvault 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for principalID in keyVaultPrincipalId: {
  name: guid(keyvault.id, resourceGroup().id, principalID)
  scope: keyvault
  properties: {
    principalId: principalID
    roleDefinitionId: keyvaultOfficerRoleDefinition
  }
}]



output keyvaultName string = keyvault.name
output keyvaultResourceId string = keyvault.id
