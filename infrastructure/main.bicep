//targetScope = 'subscription'

param location string = resourceGroup().location
param prefix string
param postfix string
param env string 

param tags object = {
  Owner: 'mlops-v2'
  Project: 'mlops-v2'
  Environment: env
  Toolkit: 'bicep'
  Name: prefix
}

module uami 'modules/uami.bicep' = {
  scope: resourceGroup()
  name: uamiName
  params: {
    //github: github
    uamiName: uamiName
    location: location
  }
}

module roleAssignmentModule 'modules/role_assignment.bicep' = {
  scope: resourceGroup() // Set the scope to the target resource group
  name: 'roleAssignment'
  params: {
    contributerId: 'b24988ac-6180-42a0-ab88-20f7382dd24c'
    uamiName: uamiName
    principalId: uami.outputs.principalId    
  }
}


var baseName  = '${prefix}-${postfix}${env}'
//var resourceGroupName = 'rg-${baseName}'
var uamiName = 'uami-${baseName}'
var uniqueSuffix = substring(uniqueString(resourceGroup().id), 0, 3)
/*resource rg 'Microsoft.Resources/resourceGroups@2020-06-01' = {
  name: resourceGroupName
  location: location

  tags: 
  
}*/

// Storage Account
module st './modules/storage_account.bicep' = {
  name: 'st'
  scope: resourceGroup()
  params: {
    baseName: 'st${uniqueSuffix}${env}'
    location: location
    tags: tags
  }
}

// Key Vault
module kv './modules/key_vault.bicep' = {
  name: 'kv'
  scope: resourceGroup()
  params: {
    baseName: 'kv-${uniqueSuffix}-${baseName}'
    location: location
    tags: tags
  }
}

// App Insights
module appi './modules/application_insights.bicep' = {
  name: 'appi'
  scope: resourceGroup()
  params: {
    baseName: baseName
    location: location
    tags: tags
  }
}

// Container Registry
module cr './modules/container_registry.bicep' = {
  name: 'cr'
  scope: resourceGroup()
  params: {
    baseName: 'cr${uniqueSuffix}${env}'
    location: location
    tags: tags
  }
}

// AML workspace
module mlw './modules/aml_workspace.bicep' = {
  name: 'mlw'
  scope: resourceGroup()
  params: {
    baseName: 'mlw-${uniqueSuffix}-${baseName}'
    location: location
    stoacctid: st.outputs.stoacctOut
    kvid: kv.outputs.kvOut
    appinsightid: appi.outputs.appinsightOut
    crid: cr.outputs.crOut
    tags: tags
  }
}

// AML compute cluster
module mlwcc './modules/aml_computecluster.bicep' = {
  name: 'mlwcc'
  scope: resourceGroup()
  params: {
    location: location
    workspaceName: mlw.outputs.amlsName
  }
}
