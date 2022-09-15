CREATE TABLE [dbo].[CleansedToSynapse](
	[PrimaryKey] [varchar](255) NOT NULL,
	[Columns] [varchar](4000) NOT NULL,
	[IncColumnName] [varchar](100) NULL,
	[LoadType] [varchar](30) NULL,
	[DataLakeContainer] [varchar](100) NOT NULL,
	[DataLakeDirectory] [varchar](100) NOT NULL,
	[DataLakeFileName] [varchar](50) NOT NULL,
	[DataLakeConnection] [varchar](50) NOT NULL,
	[DestinationSchemaName] [varchar](50) NOT NULL,
	[DestinationTableName] [varchar](50) NOT NULL,
	[DestinationConnection] [varchar](50) NOT NULL,
	[DimensionType] [tinyint] NOT NULL
)
