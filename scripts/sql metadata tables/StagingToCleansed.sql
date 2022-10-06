CREATE TABLE [dbo].[StagingToCleansed] (
  [ConnectionSecret] [nvarchar](100) NOT NULL,
  [SourceDataLakeContainer] [nvarchar](100) NOT NULL,
  [SourceDataLakeDirectory] [nvarchar](100) NOT NULL,
  [SourceDataLakeFileName] [nvarchar](50) NOT NULL,
  [DestinationDataLakeContainer] [nvarchar](100) NOT NULL,
  [DestinationDataLakeDirectory] [nvarchar](100) NOT NULL,
  [DestinationDataLakeFileName] [nvarchar](50) NOT NULL
)
GO
