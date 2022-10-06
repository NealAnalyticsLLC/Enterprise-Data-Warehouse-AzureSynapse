param project_name string
param env string
param sqldw_server_name string = 'syndwserver-${project_name}-${env}'
param sqldw_name string = 'syndw-${project_name}-${env}'
param sqldw_admin_user string
param sqldw_admin_password string
param location string
param servers_admin_name string
param servers_admin_sid string
param tenantId string
param log_analytics_workspace_id string

resource servers_datawarehouse_name_resource 'Microsoft.Sql/servers@2019-06-01-preview' = {
  name: sqldw_server_name
  location: location
  tags: {}
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    administratorLogin: sqldw_admin_user
    administratorLoginPassword: sqldw_admin_password
    version: '12.0'
    minimalTlsVersion: '1.2'
    publicNetworkAccess: 'Enabled'
  }
}

resource servers_metadata_name_ActiveDirectory 'Microsoft.Sql/servers/administrators@2019-06-01-preview' = {
  parent: servers_datawarehouse_name_resource
  name: 'ActiveDirectory'
  properties: {
    administratorType: 'ActiveDirectory'
    login: servers_admin_name
    sid: servers_admin_sid
    tenantId: tenantId
  }
}

resource servers_datwarehouse_db_name 'Microsoft.Sql/servers/databases@2020-08-01-preview' = {
  parent: servers_datawarehouse_name_resource
  name: sqldw_name
  location: location
  tags: {}
  sku: {
    name: 'DataWarehouse'
    tier: 'DataWarehouse'
    capacity: 900
    
  }
  properties: {
    collation: 'SQL_Latin1_General_CP1_CI_AS'
    catalogCollation: 'SQL_Latin1_General_CP1_CI_AS'
    
  }
}

resource diagnostic_log_dev_resource_name 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview'={
  name:'diagnostic'
  properties:{
    workspaceId:log_analytics_workspace_id
  }
  scope:servers_datwarehouse_db_name
}

output sqldw_name string = servers_datwarehouse_db_name.name
output sqldw_resource_id string = servers_datawarehouse_name_resource.id
output sqldw_server_name string = sqldw_server_name

