targetScope = 'subscription'

var subscriptionId = subscription().subscriptionId
var tenantId = subscription().tenantId
param deploymentLocation string = ''
param projectName string = ''
param Environment string =''
param SqlAdminUser string = ''
@secure()
param SqlAdminPassword string = ''
param SqlDatawarehouseAdminUser string = ''
@secure()
param SqlDatawarehouseAdminPassword string = ''
param SqlServerSID string = ''
param SqlServerAdminName string = ''
@description('adding prefix to every resource names')
var resourceprefix = take(uniqueString(deployment().name),5)



resource rgIngest 'Microsoft.Resources/resourceGroups@2020-10-01' = {
  name: 'rg-${projectName}-datalanding-dev-001'
  location: deploymentLocation
  tags:{
    'Environment':'Dev'
    'ProjectName':'NDPF'
    'Billable':'No'
    'Budget':'1000'
  }
}

resource rgGovernance 'Microsoft.Resources/resourceGroups@2020-10-01' = {
  name: 'rg-${projectName}-datagovernance-dev-001'
  location: deploymentLocation
  tags:{
    'Environment':'Dev'
    'ProjectName':'NDPF'
    'Billable':'No'
    'Budget':'1000'
  }
}

resource rgManagement 'Microsoft.Resources/resourceGroups@2020-10-01' = {
  name: 'rg-${projectName}-management-dev-001'
  location: deploymentLocation
  tags:{
    'Environment':'Dev'
    'ProjectName':'NDPF'
    'Billable':'No'
    'Budget':'1000'
  }
}

module AzDataFactoryDeploy 'data-landing-zone/ingest-template.bicep' = {
  name: 'adf-${resourceprefix}'
  scope: rgIngest
  params:{
    project_name : projectName
    env : Environment
    subscriptionId : subscriptionId
    location:deploymentLocation
    log_analytics_workspace_id:AzMonitoringDeploy.outputs.log_analytics_workspace_id
    sqldb_metadata_name:AzDataFactoryMetadataDeploy.outputs.sql_db_name
    servers_metadata_name:AzDataFactoryMetadataDeploy.outputs.sql_server_name
    vaults_BIKeyVault_name:AzDataFactoryMetadataDeploy.outputs.vaults_BIKeyVault_name
    servers_datawarehouse_name:AzSynapseDeploy.outputs.sqldw_server_name
    storageAccounts_datalake_name:AzDatalakeDeploy.outputs.adls_name
    
  }
  dependsOn:[
    AzMonitoringDeploy
    AzSynapseDeploy
    AzDataFactoryMetadataDeploy
    AzDatalakeDeploy
  ]
}

module AzDataFactoryMetadataDeploy 'data-landing-zone/metadata-template.bicep' = {
  name: 'metadata-${resourceprefix}'
  scope: rgIngest
  params:{
    servers_admin_sid:SqlServerSID
    servers_admin_name: SqlServerAdminName
    tenantId : tenantId
    project_name : projectName
    env : Environment
    sql_admin_user:SqlAdminUser
    sql_admin_password:SqlAdminPassword
    sqldw_admin_user:SqlDatawarehouseAdminUser
    sqldw_admin_password:SqlDatawarehouseAdminPassword
    sqldw_server_name:AzSynapseDeploy.outputs.sqldw_server_name
    sqldw_name:AzSynapseDeploy.outputs.sqldw_name
    subscriptionId : subscriptionId
    location:deploymentLocation
    log_analytics_workspace_id:AzMonitoringDeploy.outputs.log_analytics_workspace_id
    adls_resource_id:AzDatalakeDeploy.outputs.adls_resource_id
    
    
  }
  dependsOn:[
    AzMonitoringDeploy
  ]
}


module AzSynapseDeploy 'data-landing-zone/synapse-template.bicep' = {
  name: 'synapse-${resourceprefix}'
  scope:rgIngest
  params:{
    project_name : projectName
    env : Environment
    sqldw_admin_user:SqlDatawarehouseAdminUser
    sqldw_admin_password:SqlDatawarehouseAdminPassword
    location:deploymentLocation
    servers_admin_name:SqlServerAdminName
    servers_admin_sid:SqlServerSID
    tenantId:tenantId
    log_analytics_workspace_id:AzMonitoringDeploy.outputs.log_analytics_workspace_id
  }
  dependsOn:[
    AzMonitoringDeploy
    AzDatalakeDeploy
  ]
  
}

module AzMonitoringDeploy 'data-landing-zone/monitoring-template.bicep' = {
  name: 'monitoring-${resourceprefix}'
  scope:rgManagement
  params:{
    project_name : projectName
    location:deploymentLocation
  }
  
}

module AzDatalakeDeploy 'data-landing-zone/datalake-template.bicep' = {
  name: 'storage-${resourceprefix}'
  scope:rgIngest
  params:{
    project_name : projectName
    location:deploymentLocation
    env: Environment
    log_analytics_workspace_id:AzMonitoringDeploy.outputs.log_analytics_workspace_id
    
  }
  
}

module AzPurviewDeploy 'data-management-zone/governance-template.bicep' = {
  name: 'purview-${resourceprefix}'
  scope: rgGovernance
  params:{
        
        project_name : projectName
        location:deploymentLocation
        env : Environment
        log_analytics_workspace_id:AzMonitoringDeploy.outputs.log_analytics_workspace_id
      
    }
    dependsOn:[
      AzMonitoringDeploy
    ]
}

module AzContributorAccessDeploy 'data-landing-zone/contributor-access-template.bicep' = {
  name: 'contributor-${resourceprefix}'
  scope:rgIngest
  params:{
    subscriptionId:subscriptionId
    adf_name:AzDataFactoryDeploy.outputs.adf_name
    adls_name:AzDatalakeDeploy.outputs.adls_name
    sql_server_name: AzDataFactoryMetadataDeploy.outputs.sql_server_name
      }
  
}


