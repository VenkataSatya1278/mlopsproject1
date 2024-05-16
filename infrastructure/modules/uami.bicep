@description('The name for the user-assigned managed identity')
param uamiName string
param location string





resource uami 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: uamiName
  location: location
  
}

output principalId string = uami.properties.principalId



