param subscriptionId string = subscription().subscriptionId
param tenantId string = subscription().tenantId
param location string = resourceGroup().location
param project_name string
param vaults_BIKeyVault_name string = 'kv${project_name}${env}777'
//param dataFactories_adf_name string
param storageAccounts_datalake_name string = 'dls${project_name}${env}'

param log_analytics_workspace_id string


@description('Deployment environment')
param env string = 'dev'

@description('Name of the resource')
param sqldb_metadata_name string = 'sqldb-${project_name}-${env}'
param servers_metadata_name string = 'sqldbserver-${project_name}-${env}'
param servers_admin_name string 
param sql_admin_user string 
param sql_admin_password string 
param servers_admin_sid string 
param adls_resource_id string
param sqldw_admin_user string
param sqldw_admin_password string
param sqldw_server_name string
param sqldw_name string

resource servers_metadata_name_resource 'Microsoft.Sql/servers@2019-06-01-preview' = {
  name: servers_metadata_name
  location: location
  tags: {}
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    administratorLogin: sql_admin_user
    administratorLoginPassword: sql_admin_password
    version: '12.0'
    minimalTlsVersion: '1.2'
    publicNetworkAccess: 'Enabled'
  }
}

resource servers_metadata_name_ActiveDirectory 'Microsoft.Sql/servers/administrators@2019-06-01-preview' = {
  parent: servers_metadata_name_resource
  name: 'ActiveDirectory'
  properties: {
    administratorType: 'ActiveDirectory'
    login: servers_admin_name
    sid: servers_admin_sid
    tenantId: tenantId
  }
}



resource servers_metadata_name_sqldb_metadata_name 'Microsoft.Sql/servers/databases@2020-08-01-preview' = {
  parent: servers_metadata_name_resource
  name: sqldb_metadata_name
  location: location
  tags: {}
  sku: {
    name: 'Standard'
    tier: 'Standard'
    capacity: 20
  }
  kind: 'v12.0,user'
  properties: {
    collation: 'SQL_Latin1_General_CP1_CI_AS'
    maxSizeBytes: 2147483648
    catalogCollation: 'SQL_Latin1_General_CP1_CI_AS'
    zoneRedundant: false
    readScale: 'Disabled'
    storageAccountType: 'LRS'
  }
}

  // dependsOn: [
  //   servers_metadata_name_sqldb_metadata_name
  //   resourceId('Microsoft.OperationalInsights/workspaces', log_analytics_workspace_name)
  // ]
  resource diagnostic_log_dev_resource_name 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview'={
    name:'diagnostic'
    properties:{
      workspaceId:log_analytics_workspace_id
    }
    scope:servers_metadata_name_sqldb_metadata_name
  }
  
resource vaults_kvadfmetadatadev_name_resource 'Microsoft.KeyVault/vaults@2021-11-01-preview' = {
  name: vaults_BIKeyVault_name
  location: location
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: tenantId
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Deny'
      ipRules: []
      virtualNetworkRules: [
            ]
    }
    accessPolicies: [
      
    ]
    enabledForDeployment: false
    enabledForDiskEncryption: false
    
    enabledForTemplateDeployment: true
    // enableSoftDelete: false
    enableRbacAuthorization: false
    vaultUri: 'https://${vaults_BIKeyVault_name}.vault.azure.net/'
    provisioningState: 'Succeeded'
    publicNetworkAccess: 'Enabled'
    softDeleteRetentionInDays:7
  }
}

resource diagnostic_keyvult_resource_name 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview'={
  name:'diagnostic_keyvault'
  properties:{
    workspaceId:log_analytics_workspace_id
  }
  scope:vaults_kvadfmetadatadev_name_resource
}

resource sqldb_connection_secret_resource 'Microsoft.KeyVault/vaults/secrets@2021-11-01-preview' ={
  parent:vaults_kvadfmetadatadev_name_resource
  name: 'AzureSQLDBConnection'
  properties:{
    contentType:'string'
    value: 'Server=${servers_metadata_name}.database.windows.net;Database=${sqldb_metadata_name};User Id=${sql_admin_user};Password=${sql_admin_password}'
  }
}

  resource sqldw_connection_secret_resource 'Microsoft.KeyVault/vaults/secrets@2021-11-01-preview' ={
    parent:vaults_kvadfmetadatadev_name_resource
    name: 'SynDBConnection'
    properties:{
      contentType:'string'
      value: 'Server=${sqldw_server_name}.database.windows.net;Database=${sqldw_name};User Id=${sqldw_admin_user};Password=${sqldw_admin_password}'
    }

}

resource sqldwmasterDB_connection_secret_resource 'Microsoft.KeyVault/vaults/secrets@2021-11-01-preview' ={
  parent:vaults_kvadfmetadatadev_name_resource
  name: 'SynMasterDBConnection'
  properties:{
    contentType:'string'
    value: 'Server=${sqldw_server_name}.database.windows.net;Database=master;User Id=${sqldw_admin_user};Password=${sqldw_admin_password}'
  }

}

resource adlskey_secret_resource 'Microsoft.KeyVault/vaults/secrets@2021-11-01-preview' ={
  parent:vaults_kvadfmetadatadev_name_resource
  name: 'ADLSKey'
  properties:{
    contentType:'string'
    value: listKeys(adls_resource_id, '2019-04-01').keys[0].value
  }

}

output sql_db_name string = servers_metadata_name_resource.name
output sql_db_resource_id string = servers_metadata_name_resource.id
output sql_server_name string = servers_metadata_name
output vaults_BIKeyVault_name string = vaults_BIKeyVault_name
output sqldb_connection_secret string = sqldb_connection_secret_resource.name
output sqldw_connection_secret string = sqldw_connection_secret_resource.name
output sqldwmasterDB_connection_secret string = sqldwmasterDB_connection_secret_resource.name
output adlskey_secret string = adlskey_secret_resource.name
