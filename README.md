# Enterprise-Data-Warehouse-AzureSynapse

**Overview**

**Introduction**

The primary goal is to build an enterprise data warehouse solution using Azure services to accelerate an organization's journey to build their BI dashboards.

**Logical**  **Architecture**  **–**

![](RackMultipart20220905-1-ytso0b_html_536f35957b279f6c.png)

- **Azure Data Factory** use the metadata stored in **Azure SQL DB** and pull data from different data sources.
- Azure Data Factory stores all the source data into **Data Lake** Raw zone. After some transformations, data gets stored into Data Lake Bronze and Silver zone.
- Using **Synapse** , Data Factory do some transformations and final data gets stored into Synapse Datawarehouse.
- Data stored into Synapse Datawarehouse will be available for Power BI visualization.

**Getting Started**

**Prerequisites**

To successfully deploy this solution, you will need to have access to and/or provision the following resources:

- [Azure Subscription](https://portal.azure.com/) with owner access - Required to deploy azure resources
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) installed - Required for deployment scripts to be run locally (optional)

## AZURE RESOURCES DEPLOYMENT

The resources in this folder can be used to deploy the required cloud services into your Azure Subscription. This can be done either via the [Azure Portal](https://portal.azure.com/) or by using the [PowerShell script](https://github.com/microsoft/Azure-Non-Fungible-Token-Solution-Accelerator/blob/main/deployment/ARMTemplates/Bicep/resourcedeployment.ps1) included in the deployment folder.

After deployment, you will have an Azure Data Lake Storage Gen 2 Registry, Azure Data Factory, Azure Key Vault, Azure SQL Server, and Azure SQL Dedicated Pool along with Log Analytics.

Resources can also be deployed into your Azure Subscription by using Deploy Azure link:

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fadlsndpfdev.blob.core.windows.net%2Farm-templates%2Fmain.json)

**NOTE (for deploying using PowerShell script)**:

You can use this [link](https://azure.microsoft.com/en-in/global-infrastructure/geographies/#geographies) to choose from and decide deployment locations _ **\<deployment-location\>** _ according to your requirements.

**Before deploying the code, you'll have to edit the parameters in the code**

Below are the steps to edit the parameters in the main.bicep file.

**Step 1:**

Open the main.bicep file from the downloaded package.

On the top you'll see several parameters defined as follows:

  1. **param deploymentlocation string = '\<deployment-location\>'**

  This parameter is for the location of the deployment to take place, that is in which Azure region you wish to deploy the resources. Replace **\<deployment-location\>** with the value of location you want.

  For e.g., if you want to deploy in EAST US then it will be

  **param deploymentlocation string = 'eastus'**

  2. **param project\_name string = '\<project-name\>'**

  This parameter is for the name of the project that you want to give. Replace **\<project-name\>** with the name of project you want.

  1. **param env string ='\<environment of development\>'**

  This parameter is for the environment of the development the resources are in. Replace **\<environment of development\>** with the environment of development for e.g.,

  **dev** for Development environment, **uat** for testing environment and **prod** for Production environment.

  1. **param sql\_admin\_user string = '\<sqldbserver-user-id\>'**

  This parameter is for the username of the SQL db server admin that you want to give.

  Replace **\<sqldbserver-user-id\>** with any username of your choice.

  For e.g., **param sql\_admin\_user string = 'sqladmin'**

  1. **param sql\_admin\_password string = '\<sqldbserver-password\>'**

  This parameter is for the password of the sql db server that you want to give.

  Replace **\<sqldbserver-password\>** with any username of your choice. Please follow this [link](https://docs.microsoft.com/en-us/sql/relational-           databases/security/password-policy?view=sql-server-ver16) to check the password policy for Azure SQL Server.

  1. **param sqldw\_admin\_user string = '\<sql-dedicatedpool-server-user-id\>'**

  This parameter is for the username of the dedicated SQL pool server admin that you want to give.

  Replace **\<sql-dedicatedpool-server-user-id\>** with any username of your choice.

  For e.g., **param sqldw\_admin\_user string = 'sqldwadmin'**

  1. **param sqldw\_admin\_password string = '\<sql-dedicatedpool-server-password\>'**

  This parameter is for the password of the dedicated SQL pool server that you want to give. Replace **\<sql-dedicatedpool-server-password\>** with any username of your choice. Please follow this [link](https://docs.microsoft.com/en-us/sql/relational-databases/security/password-policy?view=sql-server-ver16) to check the password policy.

  1. **param servers\_admin\_sid string = '\<sql-sever-admin-sid\>'**

  This parameter is for the SID of the SQL Server Admin that is required for setting up Azure Active Directory login for SQL Server. Replace **\<sql-sever-admin-sid\>** with the SID of the person that you want to keep as admin.

Retrieve the **Active Directory SID** (object ID) of the admin from **Azure Active Directory** (AAD) section on **Azure Portal** as follows

  - G ![](RackMultipart20220905-1-ytso0b_html_404ee0f57a913e23.png)
 o to the Azure Active Directory section from Azure portal.

  - G ![](RackMultipart20220905-1-ytso0b_html_bbe21d891151f7ff.png)
 o to Users section from side panel

  - S ![](RackMultipart20220905-1-ytso0b_html_2c9b3d29d643895f.png)
 earch for the **User** you want as AAD admin and select it.

  - C ![](RackMultipart20220905-1-ytso0b_html_e8dbbdb164f1a34c.png)
 opy the **Object ID** from below, also known as the **SID** and paste it in the parameter section.

1. **param servers\_admin\_name string = '\<sql-server-admin-emailid\>'**

This parameter is for the email-id of the SQL Server Admin that is required for setting up Azure Active Directory login for SQL Server. Replace **\<sql-server-admin-emailid\>** with the email-id of the person that you want to keep as admin.

**Configuration**

The following configurations are required and automatically gets created with deployment

1. **Key vault Secrets –**

The following secrets would be created in key vault with deployment.

- AzureSQLDBConnection - Required to connect Azure SQL DB
- SynDBConnection - Required to connect Synapse database
- SynMasterDBConnection - Required to connect Master database of Synapse
- ADLSKey - Required to store ADLS keys

1. **ADF Linked Services (ARM Template):**

Linked services to the following resources will be created through ARM template

- Key vault
- Data lake
- Azure SQL DB
- Synapse Dedicated SQL Pool
- Synapse Master DB

1. **ADF Networking:**

Following Private endpoints will be created for the following resources

- Private endpoint for SQL DB
- Private endpoint for Synapse
- Private endpoint for Data Lake
- Private endpoint for the key vault

1. **ADF Permission (ARM template):**

- SQL DB Contributor access to SQL DB
- Blob data contributor to the Data Lake

1. **Diagnostic settings:**

- Enable all services to log data into log analytics

**Note:**

- SQL Credential for Metadata/Synapse DB: parameter is used for username/password
- Provided username/password is used to create the connection string for DBs for ADF linked services

The following configurations are required and needs to be done after deployment -

1. **Meta Data SQL Database**

You need to run the SQL script shared with code in Azure SQL DB to create below meta data tables.

**ER Diagram**  **–**

![](RackMultipart20220905-1-ytso0b_html_ae20eff6139d44bc.png)

1. **SourceToStaging –** Purpose of this table is to store source related details and data lake storage details which will be useful in data pipeline to copy data from source to ADLS.

**Example** :

INSERTINTO [dbo].[SourceToStaging]([ServerName], [DatabaseName], [SchemaName], [TableName], [Query], [ConnectionSecret], [DataLakeContainer], [DataLakeDirectory], [DataLakeFileName])

VALUES('DESKTOPServer', 'Adventure Works', 'SalesLT', 'Address', 'Select \* from SalesLT.Address','ADLSConnection', 'Staging', 'AdventureWorks','Address.parquet')

1. **StagingToCleansed** – The Purpose of this table is to store the details about the tables from staging stage to cleansed stage.

**Example:**

INSERTINTO [dbo].[StagingToCleansed]([ConnectionSecret], [SourceDataLakeContainer], [SourceDataLakeDirectory], [SourceDataLakeFileName], [DestinationDataLakeContainer], [DestinationDataLakeDirectory], [DestinationDataLakeFileName])

VALUES('ADLSConnection', 'Staging', 'AdventureWorks', 'Address.parquet', 'Cleansed', 'AdventureWorks', 'Address.parquet')

1. **CleansedToSynapse** – This table will store synapse database details like synapse table name, schema, columns, column name for incremental pull etc. Also, it will store ADLS details in the fields for Cleansed data.

**Example** :

INSERTINTO [dbo].[CleansedToSynapse]([PrimaryKey], [Columns], [IncColumnName], [LoadType], [DataLakeContainer], [DataLakeDirectory], [DataLakeFileName], [DataLakeConnection], [DestinationSchemaName], [DestinationTableName], [DestinationConnection], [DimensionType])

VALUES('AddressID', 'AddressLine1,City,StateProvince,CountryRegion', 'DateModified', 'Incremental',

'Cleansed', 'AdventureWorks', 'Address.parquet', 'ADLSConnection', 'dim', 'Address', 'SynapseConnection','1')

1. **DataValidation** – This table will store all the data required for validation of data copied from source.

**Example** :

INSERTINTO [dbo].[DataValidation]([Id], [DataSource], [ValidationRule], [ValidationCondition], [ColumnName], [FileName], [DirectoryName], [ContainerName], [TableName])

VALUES ('1', 'SQL', 'primary key column cannot be null or blank ',"toString(isNull(toString(byName('AddressId'))))", 'AddressId', 'Address.parquet', 'AdventureWorks', 'Cleansed', 'Address')

1. **ActivityLogs** – This table will store the logs of copy activities used to copy data from the source and logs of pipeline execution.

**Example** :

INSERTINTO [dbo].[ActivityLogs]([activity\_id], [activity\_name], [activity\_type], [pipeline\_id], [pipeline\_name], [pipeline\_run\_id], [trigger\_id], [event\_status], [pipeline\_exe\_status], [rows\_processed], [started\_dttm], [finished\_dttm], [datetime\_created], [datetime\_modified], [updated\_by])

VALUES ('f2068677-4d6e-45bc-b9d2-5a2bcd730a87', 'cp\_sql\_data\_to\_staging', 'copy activity', 'fe6b50cc-07c4-4043-abb5-c976996db009', 'PL\_SQL\_Source\_To\_Synapse', 'd774c88b-3ddd-4305-b54b-1382d056b407', 'b54f5cf6-9853-4422-9562-f8e15718dc5f', 'Succeeded', 'Succeeded', '15', '2022-04-07 05:40:59.363', '2022-04-07 05:40:59.363', '2022-04-07 05:40:59.363', '2022-04-07 05:40:59.363','org\user1')

1. **Key vault Secrets –**

You will need to add one more secret for connecting to the data source. For example, if your data source is On-Prem SQL server then value of secret will be in following format:

_Server=servername;Database=DBName;User Id=username;Password=Pswd;_

1. **Managed private endpoint approval**

- The data resources **ADLS** , **Azure SQL DB**** Server **and** Azure Dedication SQL Pool ****Server** and **Azure**** Key Vault** are under ADF managed virtual network for added security.
- After the ARM template deployment is done, we must approve the managed private endpoints that will be created, to include the resources under the virtual network.
- Follow the below steps to approve the connections (this example is for one resource-ADLS, follow the same steps for rest of the resources):
  - **Step 1:** Go to the ADLS resource and go to the **Networking** section.
  - **S ![](RackMultipart20220905-1-ytso0b_html_5bcd76fb4136de41.png)
 tep 2:** Under the Private endpoint connections pane, select the pending connection and approve it.

  - **Step 3:** Do the same for rest of the resources, Azure SQL DB Server, Azure Key Vault and Azure Dedication SQL Pool Server

**Data Pipelines**

- **How to build a pipeline -**

Consider, you are creating pipeline for On Premises SQL server as source, then basic steps of pipeline creation will be as follows:

1. Create Integration Runtime based on access to your source. You can refer following link for creating Integration Runtime.

[https://docs.microsoft.com/en-us/azure/data-factory/concepts-integration-runtime](https://docs.microsoft.com/en-us/azure/data-factory/concepts-integration-runtime)

1. For connecting to the source data server, create Linked Service which will connect to source using credentials stored in azure key vault secret. Fetch the connection secret using Key vault linked service which is created in deployment as shown in below image.

![](RackMultipart20220905-1-ytso0b_html_c884b8cde697b7e4.png)

You can refer below link for creation of linked service –

[https://docs.microsoft.com/en-us/azure/data-factory/concepts-linked-services?tabs=data-factory](https://docs.microsoft.com/en-us/azure/data-factory/concepts-linked-services?tabs=data-factory)

1. Create new datasets for source and sink. Source dataset will point to the source and use linked service created in previous step. And sink dataset will point to ADLS linked service created through deployment.

Follow below link for more details about creating dataset.

[https://docs.microsoft.com/en-us/azure/data-factory/v1/data-factory-create-datasets](https://docs.microsoft.com/en-us/azure/data-factory/v1/data-factory-create-datasets)

1. Create a new pipeline by going to Author section of ADF. For more details go through below link.

[https://docs.microsoft.com/en-us/azure/data-factory/quickstart-create-data-factory-portal](https://docs.microsoft.com/en-us/azure/data-factory/quickstart-create-data-factory-portal)

You can refer below screenshot to create pipeline to copy data from source to Synapse through ADLS. In this Master pipeline, child pipelines are executed to move data to different stages.

![](RackMultipart20220905-1-ytso0b_html_2b20668783e4d7b1.png)

There are 4 types of pipelines that can be build depending on the requirements.

1. Historical Pipelines
2. Incremental Pipelines
3. Archive pipelines
4. Quality Check Pipelines

**Report Development**

**How to use Synapse in Power BI**

Following are the steps to connect Synapse in power BI –

1. In Power BI Desktop click on **Get data** and then select Azure SQL Database as a source.

![](RackMultipart20220905-1-ytso0b_html_3742e5b5a29f460f.png)

1. New screen will pop-up to fill server, database, Data Connectivity mode and SQL query which is optional. Fill server and database name.

![](RackMultipart20220905-1-ytso0b_html_7f2e98be3baf9d7a.png)

1. Then PBI will ask for credentials to connect to the synapse database. Select the appropriate authentication method which you want to use for connection and put necessary credentials. For example –

![](RackMultipart20220905-1-ytso0b_html_cae167091def1d70.png)

1. PBI will show to all the tables which are present in the database. Select the table from the database which you want to use in the report.
2. Load the table in the power BI desktop and create visual using that data.

**Recommendations**

- **Performance**

- **Synapse Dedicated Pool** - Pause the synapse dedicated SQL pool after completion of pipeline execution and resume the pool in the start of pipeline execution. It will help to reduce the azure cost. For example, you can create ADF pipeline using code snippet included in below document.

![](RackMultipart20220905-1-ytso0b_html_77eef5501e91edaa.gif)

- **Pipeline Categorization** - Categorize pipelines based on their trigger time and on the type of data source.It is better to reduce dependencies between the master pipeline and child pipelines.
- **Householding Columns** - Use householding columns like pipeline id, triggered, created date, and Updated date. It will be useful to do a better audit trail.
- **Linked Services** - Linked Services should be dynamic enough to handle different source connections. Recommendation is to use dynamic parameters in linked service to make it generic. Access all credentials from Azure Key Vault. So that it will work for all environments.
- **Data Lake File Names** - Instead of deleting files before copying, use DateTimeStamp in file names while storing files in ADLS.
- **Naming conventions recommendations**

  - Pipeline - PL\_[Source Name/Phase]\_[Destination Phase]\_{DestinationObject}|{"ALL"}
  - Dataset - DS\_[SRC/INT/DST]\_[Data Set Name/Phase]\_{Object}|{"ALL"}
  - Linked Service - LS\_[Source Name/Phase]
  - Trigger - TR\_[Project Group]\_[JobID]\_[Frequency]

- **Integration runtime nodes** - It is better to start with at least two nodes for integration runtime. If the plan is to increase the number of pipelines which has the same scheduled, then Integration runtime node should also increase.
- **Integration Runtime** - Use same naming convention for Integration Runtime in all environments. Otherwise, it will start creating dependency in ADF pipelines. Once we deploy the pipelines in another environment, it will start searching IR with the different IR name.
- **Pipeline Schedule** - Instead of having the same schedule for all pipelines it can also be categorized by business priority.

- **Monitoring and Alert**

- **Alerts** - Configure email alerts in azure data factory pipelines on failure of pipeline execution.

- **Security**

- **RBAC** - Enable Role Based Access Control for containers available in ADLS.
- **Key Vaults** – Use Azure Key vaults for storing credentials or secrets.

- **Cost Management**

- **Budget alerts** - Use budget alerts. Budget alerts notify you when spending, based on usage or cost, reaches or exceeds the amount defined in the [alert condition of the budget](https://docs.microsoft.com/en-us/azure/cost-management-billing/costs/tutorial-acm-create-budgets). Cost Management budgets are created using the Azure portal or the [Azure Consumption](https://docs.microsoft.com/rest/api/consumption) API.

For any questions, contact [support@nealanalytics.com](mailto:support@nealanalytics.com)

16
