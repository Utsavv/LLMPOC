CREATE TABLE [Person].[BusinessEntity]
(
[BusinessEntityID] [int] NOT NULL IDENTITY(1, 1) NOT FOR REPLICATION,
[rowguid] [uniqueidentifier] NOT NULL ROWGUIDCOL CONSTRAINT [DF_BusinessEntity_rowguid] DEFAULT (newid()),
[ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_BusinessEntity_ModifiedDate] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [Person].[BusinessEntity] ADD CONSTRAINT [PK_BusinessEntity_BusinessEntityID] PRIMARY KEY CLUSTERED ([BusinessEntityID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [AK_BusinessEntity_rowguid] ON [Person].[BusinessEntity] ([rowguid]) ON [PRIMARY]
