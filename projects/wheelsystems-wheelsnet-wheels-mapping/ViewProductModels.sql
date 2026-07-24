USE [WheelSystems]
GO

IF OBJECT_ID('dbo.ViewProductModels', 'V') IS NOT NULL
    DROP VIEW dbo.ViewProductModels
GO

/*
    ViewProductModels
    -----------------
    ProductModels originali (esclusi TypeId 2,3 = cerchi)
    UNION ALL
    ProductModels sintetici derivati da [WheelsNet].dbo.Wheels

    ID sintetici: 1999999 + DENSE_RANK() OVER (ORDER BY BrandId, Model, ProductTypeId)
    Questa espressione DEVE essere identica in ViewWhVersions e ViewProducts
    per garantire coerenza referenziale tra le 3 viste.

    Base offset 1999999 scelto perche' ProductModels.Id arriva a ~1.004.967.
*/
CREATE VIEW dbo.ViewProductModels
AS

-- Parte 1: ProductModels originali (pneumatici + accessori)
SELECT
    pm.[Id]
    ,pm.[RowState]
    ,pm.[InsDate]
    ,pm.[InsUserId]
    ,pm.[UpdDate]
    ,pm.[UpdUserId]
    ,pm.[BrandId]
    ,pm.[Descr]
    ,pm.[ExtendedDescr]
    ,pm.[ProductTypeId]
    ,pm.[TyTypeId]
    ,pm.[TySeasonId]
    ,pm.[TyManufactureTypeId]
    ,pm.[WhSpokes]
    ,pm.[WhManufactureTypeId]
    ,pm.[WhManufacturePieces]
FROM dbo.ProductModels pm
WHERE pm.ProductTypeId NOT IN (2, 3)

UNION ALL

-- Parte 2: ProductModels sintetici da Wheels (cerchi ferro + lega)
SELECT
    [Id]                    = CAST(w.ModelId AS INT)
    ,[RowState]             = 1
    ,[InsDate]              = w.MinTimestamp
    ,[InsUserId]            = CAST(NULL AS INT)
    ,[UpdDate]              = w.MaxTimestamp
    ,[UpdUserId]            = CAST(NULL AS INT)
    ,[BrandId]              = w.BrandOldId
    ,[Descr]                = CAST(w.Model AS NVARCHAR(MAX))
    ,[ExtendedDescr]        = CAST(NULL AS NVARCHAR(MAX))
    ,[ProductTypeId]        = w.ProductTypeId
    ,[TyTypeId]             = CAST(NULL AS INT)
    ,[TySeasonId]           = CAST(NULL AS INT)
    ,[TyManufactureTypeId]  = CAST(NULL AS NCHAR(1))
    ,[WhSpokes]             = CAST(NULL AS INT)
    ,[WhManufactureTypeId]  = w.MaterialId
    ,[WhManufacturePieces]  = CAST(NULL AS INT)
FROM (
    SELECT
        ModelId       = 1999999 + DENSE_RANK() OVER (ORDER BY wh.BrandId, wh.Model, wh.ProductTypeId)
        ,BrandOldId   = MAX(b.OldId)
        ,Model        = wh.Model
        ,ProductTypeId = wh.ProductTypeId
        ,MaterialId   = MAX(wh.MaterialId)
        ,MinTimestamp  = MIN(wh.[Timestamp])
        ,MaxTimestamp  = MAX(wh.[Timestamp])
    FROM [WheelsNet].dbo.Wheels wh
    LEFT JOIN [WheelsNet].dbo.Brands b ON b.Id = wh.BrandId
    GROUP BY wh.BrandId, wh.Model, wh.ProductTypeId
) w

GO
