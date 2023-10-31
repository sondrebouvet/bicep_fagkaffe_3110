/**
* Adds storage account key to an exisitng keyvault
*/

@description('Name for the key vault')
param keyVaultName string



@description('Storage account name')
param storageAccountName string 

@description('ID of storage acccount')
param storageAccountId string 

@description('Storage account key')
var storageAccountKey = !empty(storageAccountId) ? listKeys(storageAccountId, '2021-06-01').keys[0].value : ''



resource keyvault 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: keyVaultName
}

resource storageAccountKeySecret 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = if(!empty(storageAccountId)) {
  name: '${storageAccountName}sasecret'
  parent: keyvault
  properties: {
    contentType: 'text/plain'
    attributes: {
      enabled: true
    }
    value: storageAccountKey
  }
}


