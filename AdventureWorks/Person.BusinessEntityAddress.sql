CREATE TABLE [Person].[BusinessEntityAddress]
(
[BusinessEntityID] [int] NOT NULL,
[AddressID] [int] NOT NULL,
[AddressTypeID] [int] NOT NULL,
[rowguid] [uniqueidentifier] NOT NULL ROWGUIDCOL CONSTRAINT [DF_BusinessEntityAddress_rowguid] DEFAULT (newid()),
[ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_BusinessEntityAddress_ModifiedDate] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [Person].[BusinessEntityAddress] ADD CONSTRAINT [PK_BusinessEntityAddress_BusinessEntityID_AddressID_AddressTypeID] PRIMARY KEY CLUSTERED ([BusinessEntityID], [AddressID], [AddressTypeID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [AK_BusinessEntityAddress_rowguid] ON [Person].[BusinessEntityAddress] ([rowguid]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_BusinessEntityAddress_AddressID] ON [Person].[BusinessEntityAddress] ([AddressID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_BusinessEntityAddress_AddressTypeID] ON [Person].[BusinessEntityAddress] ([AddressTypeID]) ON [PRIMARY]
GO
ALTER TABLE [Person].[BusinessEntityAddress] ADD CONSTRAINT [FK_BusinessEntityAddress_Address_AddressID] FOREIGN KEY ([AddressID]) REFERENCES [Person].[Address] ([AddressID])
GO
ALTER TABLE [Person].[BusinessEntityAddress] ADD CONSTRAINT [FK_BusinessEntityAddress_AddressType_AddressTypeID] FOREIGN KEY ([AddressTypeID]) REFERENCES [Person].[AddressType] ([AddressTypeID])
GO
ALTER TABLE [Person].[BusinessEntityAddress] ADD CONSTRAINT [FK_BusinessEntityAddress_BusinessEntity_BusinessEntityID] FOREIGN KEY ([BusinessEntityID]) REFERENCES [Person].[BusinessEntity] ([BusinessEntityID])
GO