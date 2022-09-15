# Overview

## Enterprise Data Warehouse - Azure Synapse 

This repository contains code to accelerate an organization’s journey to build its BI dashboards. The process of deploying the resources and configurations will be taken care of automatically. For example, the Data Factory required for the movement and transformation of data with Azure Data Lake Storage will be deployed with the required configurations. And just after creating the necessary pipelines for the transformation of the data your data will be ready to use in Power BI, Azure DB, or in Azure ML.

## Logical Architecture 
 ![Logical Architecture](https://github.com/NealAnalyticsLLC/Enterprise-Data-Warehouse-AzureSynapse/blob/dev/piyush/images/Logical%20Architecture.png)
- **Azure Data Factory** uses the metadata stored in **Azure SQL DB** and pulls data from different data sources.
- Azure Data Factory stores all the source data into **Data Lake** Raw zone. After some transformations, data gets stored in Data Lake Bronze and Silver zone.
- Using **Synapse**, Data Factory does some transformations, and the final data gets stored into Synapse Datawarehouse.
- Data stored into Synapse Datawarehouse will be available for Power BI visualization.

# Getting Started
## Prerequisites 
In order to successfully deploy this solution, you will need to have access to the following resources:
- [Azure Subscription](https://portal.azure.com/) with owner access - Required to deploy azure resources
- [Azure CLI installed](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)- Required for deployment scripts to be run locally (optional)
- Deployment Parameters (Follow steps mentioned in the next **Deployment Parameters** section)

## Azure Resource Deployment
The resources in this folder can be used to deploy the required cloud services into your Azure Subscription. This can be done either via the [Azure Portal](https://portal.azure.com) or using the below button: 

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FNealAnalyticsLLC%2FEnterprise-Data-Warehouse-AzureSynapse%2Fdev%2Fpiyush%2Fdeployment%2FARM%2520templates%2Fjson%2Fmain.json)

Also, you can use this [PowerShell script](https://github.com/NealAnalyticsLLC/Enterprise-Data-Warehouse-AzureSynapse/blob/dev/piyush/deployment/ARM%20templates/bicep/resourcedeployment.ps1) to deploy the resources locally (**make sure to replace parameters in the main.bicep file**).

After deployment, you will have an Azure Data Lake Storage Gen 2 Registry, Azure Data Factory, Azure Key Vault, Azure SQL Server, and Azure SQL Dedicated Pool along with Log Analytics.

## Deployment Parameters

1. **param deploymentLocation string = '\<deployment-location>'**
This parameter is for the location of the deployment to take place, that is in which Azure region you wish to deploy the resources. Replace <deployment-location> with the value of location you want.
For e.g., if you want to deploy in EAST US then it will be
**param deploymentLocation string = 'eastus'**

2. **param projectName string = '\<project-name>'**
This parameter is for the name of the project that you want to give(can be an abbreviation too). Replace **<project-name>** with the name of project you want.

3. **param Environment string ='\<environment of development>'**
This parameter is for the environment of the development the resources are in. Replace **<environment of development>** with the environment of development for e.g.,
**dev** for Development environment, **uat** for testing environment and **prod** for Production environment.
	
	**NOTE**: The parameters **projectName** and **Environment** value should only have lowercase letters and numbers, no special characters allowed and shouldn't be more than 5-10 letters.


4. **param SqlAdminUser string = '\<sqldbserver-user-id>'**
This parameter is for the username of the SQL db server admin that you want to give. 
Replace **<sqldbserver-user-id>** with any username of your choice.
For e.g.,  **param SqlAdminUser string = 'sqladmin'**

5. **param SqlAdminPassword string = '\<sqldbserver-password>'**
This parameter is for the password of the sql db server that you want to give. 
Replace **<sqldbserver-password>** with any username of your choice. Please follow this [link](https://docs.microsoft.com/en-us/sql/relational-databases/security/password-policy?view=sql-server-ver16) to check the password policy for Azure SQL Server.

6. **param SqlDatawarehouseAdminUser string = '\<sql-dedicatedpool-server-user-id>'**
This parameter is for the username of the dedicated SQL pool server admin that you want to give. 
Replace **<sql-dedicatedpool-server-user-id>** with any username of your choice.
For e.g., **param SqlDatawarehouseAdminUser string = 'sqldwadmin'**

7. **param SqlDatawarehouseAdminPassword string = '\<sql-dedicatedpool-server-password>'**
This parameter is for the password of the dedicated SQL pool server that you want to give. Replace **<sql-dedicatedpool-server-password>** with any username of your choice. Please follow this [link](https://docs.microsoft.com/en-us/sql/relational-databases/security/password-policy?view=sql-server-ver16) to check the password policy.

8. **param SqlServerSID string = '\<sql-sever-admin-sid>'**
It's the Object Id of User/Group and can be obtained from Azure Active Directory -> Users/Groups ->   Replace **<sql-sever-admin-sid>** with the SID of the person that you want to keep as admin.
	* Copy the **Object ID** from below, also known as the **SID** and paste it in the parameter section.
	
		![Overview](https://github.com/NealAnalyticsLLC/Enterprise-Data-Warehouse-AzureSynapse/blob/dev/piyush/images/Overview.png)

9. **param SqlServerAdminName string = '\<sql-server-admin-emailid>'**
This parameter is for the email-id of the SQL Server Admin that is required for setting up Azure Active Directory login for SQL Server. Replace **<sql-server-admin-emailid>** with the email-id of the person that you want to keep as admin.

## Configurations
### The following configurations are required and automatically gets created with deployment
#### 1.	Key vault Secrets: 
The following secrets would be created in key vault with deployment.
- AzureSQLDBConnection - Required to connect Azure SQL DB
- SynDBConnection - Required to connect Synapse database
- SynMasterDBConnection - Required to connect Master database of Synapse
- ADLSKey - Required to store ADLS keys 

#### 2.	ADF Linked Services:
Linked services to the following resources will be created through ARM template
- Key vault
- Data lake
- Azure SQL DB
- Synapse Dedicated SQL Pool
- Synapse Master DB

#### 3.	ADF Networking:
Following Private endpoints will be created for the following resources
- Private endpoint for SQL DB
- Private endpoint for Synapse
- Private endpoint for Data Lake
- Private endpoint for the key vault

#### 4.	ADF Permission:
- SQL DB Contributor access to SQL DB
- Blob data contributor to the Data Lake

#### 5.	Diagnostic settings:
- Enable all services to log data into log analytics
	
**Note:**
- SQL Credential for Metadata/Synapse DB: parameter is used for username/password
- Provided username/password is used to create the connection string for DBs for ADF linked services


### The following configurations are required and needs to be done after deployment
#### 1.	Meta Data SQL Database:
You need to run the SQL script shared with code in Azure SQL DB to create below meta data tables.

**ER Diagram –**
![MetaData Tables](https://github.com/NealAnalyticsLLC/Enterprise-Data-Warehouse-AzureSynapse/blob/dev/piyush/images/MetaData%20Tables.png)
 
1. **SourceToStaging** – Purpose of this table is to store source related details and data lake storage details which will be useful in data pipeline to copy data from source to ADLS.  
Example: 
```
INSERT INTO [dbo].[SourceToStaging]  ([ServerName], [DatabaseName], [SchemaName], [TableName], [Query], [ConnectionSecret], [DataLakeContainer], [DataLakeDirectory], [DataLakeFileName])
 VALUES ('DESKTOPServer', 'Adventure Works', 'SalesLT', 'Address', 'Select * from SalesLT.Address','ADLSConnection', 'Staging', 'AdventureWorks','Address.parquet')
```
2. **StagingToCleansed** – The Purpose of this table is to store the details about the tables from staging stage to cleansed stage.  
Example:
```
INSERT INTO [dbo].[StagingToCleansed]([ConnectionSecret], [SourceDataLakeContainer], [SourceDataLakeDirectory], [SourceDataLakeFileName], [DestinationDataLakeContainer], [DestinationDataLakeDirectory], [DestinationDataLakeFileName])
VALUES ('ADLSConnection', 'Staging', 'AdventureWorks', 'Address.parquet', 'Cleansed', 'AdventureWorks', 'Address.parquet')
```

3. **CleansedToSynapse** – This table will store synapse database details like synapse table name, schema, columns, column name for incremental pull etc. Also, it will store ADLS details in the fields for Cleansed data.  
Example:
```
INSERT INTO [dbo].[CleansedToSynapse]([PrimaryKey], [Columns], [IncColumnName], [LoadType], [DataLakeContainer], [DataLakeDirectory],  [DataLakeFileName], [DataLakeConnection], [DestinationSchemaName], [DestinationTableName], [DestinationConnection], [DimensionType])
VALUES ('AddressID', 'AddressLine1,City,StateProvince,CountryRegion', 'DateModified', 'Incremental',
'Cleansed', 'AdventureWorks', 'Address.parquet', 'ADLSConnection', 'dim', 'Address', 'SynapseConnection','1')
```

#### 2.	Key vault Secrets:
You will need to add one more secret for connecting to the data source. For example, if your data source is On-Prem SQL server then value of secret will be in following format:
Server=servername;Database=DBName;User Id=username;Password=Pswd;

#### 3.	Managed private endpoint approval:

- The data resources **ADLS**, **Azure SQL DB Server** and **Azure Dedication SQL Pool Server** and **Azure Key Vault** are under ADF managed virtual network for added security.
- After the ARM template deployment is done, we must approve the managed private endpoints that will be created, to include the resources under the virtual network.
- Follow the below steps to approve the connections (this example is for one resource-ADLS, follow the same steps for rest of the resources):
	- **Step 1:** Go to the ADLS resource and go to the **Networking section.**
	- **Step 2:** Under the Private endpoint connections pane, select the pending connection and approve it.
		
		![Adls Networking](https://github.com/NealAnalyticsLLC/Enterprise-Data-Warehouse-AzureSynapse/blob/dev/piyush/images/Adls%20Networking.png)
	- **Step 3:** Do the same for rest of the resources, Azure SQL DB Server, Azure Key Vault and Azure Dedication SQL Pool Server


# Data Pipelines 
## How to build a pipeline
	
Consider, you are creating pipeline for On Premises SQL server as source, then basic steps of pipeline creation will be as follows:
1. Create Integration Runtime based on access to your source. You can refer following link for creating Integration Runtime.
https://docs.microsoft.com/en-us/azure/data-factory/concepts-integration-runtime

2. For connecting to the source data server, create Linked Service which will connect to source using credentials stored in azure key vault secret. Fetch the connection secret using Key vault linked service which is created in deployment as shown in below image.
	
	![Key vault](https://github.com/NealAnalyticsLLC/Enterprise-Data-Warehouse-AzureSynapse/blob/dev/piyush/images/Key%20vault.png)
	
	You can refer below link for creation of linked service –
	https://docs.microsoft.com/en-us/azure/data-factory/concepts-linked-services?tabs=data-factory

3. Create new datasets for source and sink. Source dataset will point to the source and use linked service created in previous step. And sink dataset will point to ADLS linked service created through deployment.
Follow below link for more details about creating dataset.
https://docs.microsoft.com/en-us/azure/data-factory/v1/data-factory-create-datasets

4. Create a new pipeline by going to Author section of ADF. For more details go through below link.
https://docs.microsoft.com/en-us/azure/data-factory/quickstart-create-data-factory-portal
You can refer below screenshot to create pipeline to copy data from source to Synapse through ADLS. In this Master pipeline, child pipelines are executed to move data to different stages.
 
	![Master Pipeline](https://github.com/NealAnalyticsLLC/Enterprise-Data-Warehouse-AzureSynapse/blob/dev/piyush/images/Master%20Pipeline.png)

There are 4 types of pipelines that can be build depending on the requirements.
1.	Historical Pipelines
2.	Incremental Pipelines
3.	Archive pipelines

# Report Development
## How to use Synapse in Power BI
Following are the steps to connect Synapse in power BI.
1.	In Power BI Desktop click on Get data and then select Azure SQL Database as a source.
	
	![get data](https://github.com/NealAnalyticsLLC/Enterprise-Data-Warehouse-AzureSynapse/blob/dev/piyush/images/get%20data.png)
2.	New screen will pop-up to fill server, database, Data Connectivity mode and SQL query which is optional. Fill server and database name. 
	
	![sql server database](https://github.com/NealAnalyticsLLC/Enterprise-Data-Warehouse-AzureSynapse/blob/dev/piyush/images/sql%20server%20database.png)
3.	Then PBI will ask for credentials to connect to the synapse database. Select the appropriate authentication method which you want to use for connection and put necessary credentials. For example – 
	
	![connect](https://github.com/NealAnalyticsLLC/Enterprise-Data-Warehouse-AzureSynapse/blob/dev/piyush/images/connect.png)
4.	PBI will show to all the tables which are present in the database. Select the table from the database which you want to use in the report.
5.	Load the table in the power BI desktop and create visual using that data.

# Recommendations
## 1. **Performance**
- **Synapse Dedicated Pool** - Pause the synapse dedicated SQL pool after completion of pipeline execution and resume the pool in the start of pipeline execution. It will help to reduce the azure cost. For example, you can create ADF pipeline using code snippet included in below document.  
[Code for Pipeline to pause or resume Synapse](https://github.com/NealAnalyticsLLC/Enterprise-Data-Warehouse-AzureSynapse/blob/dev/piyush/Code%20for%20Pipeline%20to%20pause%20or%20resume%20Synapse#L3)

- **Pipeline Categorization** - Categorize pipelines based on their trigger time and on the type of data source. It is better to reduce dependencies between the master pipeline and child pipelines. 

- **Householding Columns** - Use householding columns like pipeline id, triggered, created date, and Updated date. It will be useful to do a better audit trail.

- **Linked Services** - Linked Services should be dynamic enough to handle different source connections. Recommendation is to use dynamic parameters in linked service to make it generic. Access all credentials from Azure Key Vault. So that it will work for all environments.

- **Data Lake File Names** - Instead of deleting files before copying, use DateTimeStamp in file names while storing files in ADLS.

- **Naming conventions recommendations**
	- Pipeline - PL_[Source Name/Phase]_[Destination Phase]_{DestinationObject}|{“ALL”} 
	- Dataset - DS_[SRC/INT/DST]_[Data Set Name/Phase]_{Object}|{“ALL”} 
	- Linked Service - LS_[Source Name/Phase] 
	- Trigger - TR_[Project Group]_[JobID]_[Frequency] 

- **Integration runtime nodes** - It is better to start with at least two nodes for integration runtime. If the plan is to increase the number of pipelines which has the same scheduled, then Integration runtime node should also increase.

- **Integration Runtime** - Use same naming convention for Integration Runtime in all environments. Otherwise, it will start creating dependency in ADF pipelines. Once we deploy the pipelines in another environment, it will start searching IR with the different IR name.
	
- **Pipeline Schedule** - Instead of having the same schedule for all pipelines it can also be categorized by business priority.

## 2. **Monitoring and Alert**
- **Alerts** - Configure email alerts in azure data factory pipelines on failure of pipeline execution.
	
## 3. **Security**
- **RBAC** - Enable Role Based Access Control for containers available in ADLS.
- **Key Vaults** – Use Azure Key vaults for storing credentials or secrets.
	
## 4. Cost Management
- **Budget alerts** - Use budget alerts. Budget alerts notify you when spending, based on usage or cost, reaches, or exceeds the amount defined in the alert condition of the budget. Cost Management budgets are created using the Azure portal or the Azure Consumption API.






