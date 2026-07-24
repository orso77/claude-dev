USE [WheelSystems]
GO

IF OBJECT_ID('dbo.ViewProducts', 'V') IS NOT NULL
    DROP VIEW dbo.ViewProducts
GO

/*
    ViewProducts
    ------------
    Products originali esclusi TypeId IN (2,3)
    UNION ALL
    Wheels da [WheelsNet].dbo.Wheels mappati alla struttura Products

    ProductModelId: 1999999 + DENSE_RANK() OVER (ORDER BY BrandId, Model, ProductTypeId)
    WhVersionId:    1999999 + DENSE_RANK() OVER (ORDER BY BrandId, VersionCode, Holes, ColorCode)

    Queste espressioni DEVONO essere identiche a quelle in ViewProductModels e ViewWhVersions.

    BrandId: Wheels.BrandId (varchar) -> Brands.OldId (int) via JOIN su [WheelsNet].dbo.Brands

    Mapping Wheels -> Products:
    - Wheels.Width       -> Products.WhWidth
    - Wheels.Diameter    -> Products.Diameter       (senza prefisso Wh)
    - Wheels.Offset      -> Products.WhOffset
    - Wheels.Pcd1/2/3    -> Products.WhPcd1/2/3
    - Wheels.MinBoreDiam -> Products.WhMinBoreDiam
    - Wheels.MaxBoreDiam -> Products.WhMaxBoreDiam
    - Wheels.IntHeft     -> Products.WhIntHeft
    - Wheels.ExtHeft     -> Products.WhExtHeft
    - Wheels.MaxLoad     -> Products.WhMaxLoad
    - Wheels.HomolCode1  -> Products.WhOmologCod    (via Ext_HomolCode)
    - Wheels.Cup         -> Products.WhCupCod1
    - Wheels.CupOe       -> Products.WhCupCod2
    - Wheels.NetWeightKg -> Products.WeightKg
    - Wheels.Ean         -> Products.EanCod
    - Wheels.ManufacturerCode -> Products.ManufacturerCod
    - Wheels.Img1        -> Products.ImgName
    - Wheels.PubblicationTypes -> Products.PubblicationTypes
*/
CREATE VIEW dbo.ViewProducts
AS

-- Parte 1: Products originali (pneumatici + accessori)
SELECT
    p.[Id]
    ,p.[RowState]
    ,p.[InsDate]
    ,p.[InsUserId]
    ,p.[UpdDate]
    ,p.[UpdUserId]
    ,p.[PubblicationTypes]
    ,p.[ProductTypeId]
    ,p.[Descr]
    ,p.[ExtDescr]
    ,p.[VatId]
    ,p.[LastPurchPrice]
    ,p.[AvgPurchPrice]
    ,p.[ListPrice]
    ,p.[BasePriceInStock]
    ,p.[BasePriceOutStock]
    ,p.[InStockDiscountProductPriceId]
    ,p.[InStockMarkUpProductPriceId]
    ,p.[OutStockDiscountProductPriceId]
    ,p.[OutStockMarkUpProductPriceId]
    ,p.[SpecialOffer]
    ,p.[BrandId]
    ,p.[ProductModelId]
    ,p.[EanCod]
    ,p.[ManufacturerCod]
    ,p.[StartRating]
    ,p.[VehicleTypes]
    ,p.[ImgName]
    ,p.[Diameter]
    ,p.[TyWidth]
    ,p.[TyAspRatio]
    ,p.[TyLoadIdx1]
    ,p.[TyLoadIdx2]
    ,p.[TySpeedId]
    ,p.[TyEcoRollResist]
    ,p.[TyEcoWetGrip]
    ,p.[TyEcoNoiseLev]
    ,p.[TyEcoNoiseDb]
    ,p.[TyMs]
    ,p.[TyRunFlat]
    ,p.[TyReinf]
    ,p.[TyCargo]
    ,p.[TyZr]
    ,p.[TyFr]
    ,p.[TyXl]
    ,p.[TyApplicationId]
    ,p.[TyMeasureFormatId]
    ,p.[TyCanvas]
    ,p.[TyDot]
    ,p.[TyDemo]
    ,p.[WhVersionId]
    ,p.[WhWidth]
    ,p.[WhOffset]
    ,p.[WhPcd1]
    ,p.[WhPcd2]
    ,p.[WhPcd3]
    ,p.[WhVarPcd]
    ,p.[WhBoltHolesWidth]
    ,p.[WhBoltHolesHeight]
    ,p.[WhFastenerTypeId]
    ,p.[WhSeatTypeId]
    ,p.[WhMinBoreDiam]
    ,p.[WhMaxBoreDiam]
    ,p.[WhIntHeft]
    ,p.[WhExtHeft]
    ,p.[WhOmologCod]
    ,p.[WhMaxLoad]
    ,p.[WhBrakesPassLimit]
    ,p.[WhCupLimit]
    ,p.[WhCupCod1]
    ,p.[WhCupCod2]
    ,p.[WhCupCod3]
    ,p.[WhCupCod4]
    ,p.[WhCupCod5]
    ,p.[WhMeasureCod]
    ,p.[WhKfzCode]
    ,p.[WhWheelCod]
    ,p.[AcATypeId]
    ,p.[AcBTypeId]
    ,p.[AcCTypeId]
    ,p.[ChTypeId]
    ,p.[BlTypeId]
    ,p.[BlDimensionId]
    ,p.[SpWidth]
    ,p.[SpAspRatio]
    ,p.[PackWidth]
    ,p.[PackLength]
    ,p.[PackHeight]
    ,p.[WeightKg]
    ,p.[WhWheelCod1]
    ,p.[WhWheelCod2]
    ,p.[TyEcoNoiseLev2]
FROM dbo.Products p
WHERE p.ProductTypeId NOT IN (2, 3)

UNION ALL

-- Parte 2: Wheels mappati alla struttura Products
SELECT
    -- Identificatori
    [Id]                              = CAST(w.Id AS NCHAR(25))
    ,[RowState]                       = 1
    ,[InsDate]                        = w.[Timestamp]
    ,[InsUserId]                      = CAST(999 AS INT)
    ,[UpdDate]                        = w.[Timestamp]
    ,[UpdUserId]                      = CAST(999 AS INT)
    ,[PubblicationTypes]              = w.PubblicationTypes
    ,[ProductTypeId]                  = w.ProductTypeId
    ,[Descr]                          = CAST(w.Descr AS NVARCHAR(MAX))
    ,[ExtDescr]                       = CAST(w.DescrEn AS NVARCHAR(MAX))

    -- Prezzi (non presenti in Wheels)
    ,[VatId]                          = CAST(1 AS INT)
    ,[LastPurchPrice]                 = CAST(NULL AS DECIMAL(9,2))
    ,[AvgPurchPrice]                  = CAST(NULL AS DECIMAL(9,2))
    ,[ListPrice]                      = CAST(0.00 AS DECIMAL(9,2))
    ,[BasePriceInStock]               = CAST(0.00 AS DECIMAL(9,2))
    ,[BasePriceOutStock]              = CAST(0.00 AS DECIMAL(9,2))
    ,[InStockDiscountProductPriceId]  = CAST(NULL AS INT)
    ,[InStockMarkUpProductPriceId]    = CAST(NULL AS INT)
    ,[OutStockDiscountProductPriceId] = CAST(NULL AS INT)
    ,[OutStockMarkUpProductPriceId]   = CAST(NULL AS INT)
    ,[SpecialOffer]                   = CAST(0 AS INT)

    -- Brand e Model
    ,[BrandId]                        = b.OldId
    ,[ProductModelId]                 = CAST(1999999 + DENSE_RANK() OVER (ORDER BY w.BrandId, w.Model, w.ProductTypeId) AS INT)
    ,[EanCod]                         = CAST(w.Ean AS NCHAR(25))
    ,[ManufacturerCod]                = CAST(w.ManufacturerCode AS NCHAR(50))
    ,[StartRating]                    = CAST(NULL AS DECIMAL(9,2))
    ,[VehicleTypes]                   = CAST(NULL AS BIGINT)
    ,[ImgName]                        = CAST(w.Img1 AS NVARCHAR(MAX))

    -- Diametro (condiviso, senza prefisso Wh)
    ,[Diameter]                       = CAST(w.Diameter AS DECIMAL(9,2))

    -- Campi Pneumatico (non applicabili ai cerchi)
    ,[TyWidth]                        = CAST(NULL AS DECIMAL(9,2))
    ,[TyAspRatio]                     = CAST(NULL AS DECIMAL(9,2))
    ,[TyLoadIdx1]                     = CAST(NULL AS DECIMAL(9,2))
    ,[TyLoadIdx2]                     = CAST(NULL AS DECIMAL(9,2))
    ,[TySpeedId]                      = CAST(NULL AS NCHAR(2))
    ,[TyEcoRollResist]                = CAST(NULL AS NVARCHAR(MAX))
    ,[TyEcoWetGrip]                   = CAST(NULL AS NVARCHAR(MAX))
    ,[TyEcoNoiseLev]                  = CAST(NULL AS INT)
    ,[TyEcoNoiseDb]                   = CAST(NULL AS INT)
    ,[TyMs]                           = CAST(NULL AS INT)
    ,[TyRunFlat]                      = CAST(NULL AS INT)
    ,[TyReinf]                        = CAST(NULL AS INT)
    ,[TyCargo]                        = CAST(NULL AS INT)
    ,[TyZr]                           = CAST(NULL AS INT)
    ,[TyFr]                           = CAST(NULL AS INT)
    ,[TyXl]                           = CAST(NULL AS INT)
    ,[TyApplicationId]                = CAST(NULL AS NCHAR(25))
    ,[TyMeasureFormatId]              = CAST(NULL AS INT)
    ,[TyCanvas]                       = CAST(NULL AS INT)
    ,[TyDot]                          = CAST(NULL AS INT)
    ,[TyDemo]                         = CAST(NULL AS INT)

    -- Campi Cerchio (prefisso Wh in Products, senza prefisso in Wheels)
    ,[WhVersionId]                    = CAST(1999999 + DENSE_RANK() OVER (ORDER BY w.BrandId, w.VersionCode, w.Holes, w.ColorCode) AS INT)
    ,[WhWidth]                        = CAST(w.Width AS DECIMAL(9,2))
    ,[WhOffset]                       = CAST(w.[Offset] AS DECIMAL(9,2))
    ,[WhPcd1]                         = CAST(w.Pcd1 AS DECIMAL(9,2))
    ,[WhPcd2]                         = CAST(w.Pcd2 AS DECIMAL(9,2))
    ,[WhPcd3]                         = CAST(w.Pcd3 AS DECIMAL(9,2))
    ,[WhVarPcd]                       = CAST(NULL AS INT)
    ,[WhBoltHolesWidth]               = CAST(NULL AS DECIMAL(9,2))
    ,[WhBoltHolesHeight]              = CAST(NULL AS DECIMAL(9,2))
    ,[WhFastenerTypeId]               = CAST(NULL AS INT)
    ,[WhSeatTypeId]                   = CAST(NULL AS INT)
    ,[WhMinBoreDiam]                  = CAST(w.MinBoreDiam AS DECIMAL(9,2))
    ,[WhMaxBoreDiam]                  = CAST(w.MaxBoreDiam AS DECIMAL(9,2))
    ,[WhIntHeft]                      = CAST(w.IntHeft AS DECIMAL(9,2))
    ,[WhExtHeft]                      = CAST(w.ExtHeft AS DECIMAL(9,2))
    ,[WhOmologCod]                    = CAST(COALESCE(NULLIF(w.HomolCode1, ''), w.HomolCode2, '') AS NVARCHAR(MAX))
    ,[WhMaxLoad]                      = CAST(w.MaxLoad AS DECIMAL(9,2))
    ,[WhBrakesPassLimit]              = CAST(NULL AS INT)
    ,[WhCupLimit]                     = CAST(NULL AS INT)
    ,[WhCupCod1]                      = CAST(NULLIF(w.Cup, '') AS NVARCHAR(MAX))
    ,[WhCupCod2]                      = CAST(NULLIF(w.CupOe, '') AS NVARCHAR(MAX))
    ,[WhCupCod3]                      = CAST(NULL AS NVARCHAR(MAX))
    ,[WhCupCod4]                      = CAST(NULL AS NVARCHAR(MAX))
    ,[WhCupCod5]                      = CAST(NULL AS NVARCHAR(MAX))
    ,[WhMeasureCod]                   = CAST(NULL AS NVARCHAR(MAX))
    ,[WhKfzCode]                      = CAST(NULL AS NCHAR(50))
    ,[WhWheelCod]                     = CAST(NULL AS NCHAR(50))

    -- Accessori (non applicabili)
    ,[AcATypeId]                      = CAST(NULL AS INT)
    ,[AcBTypeId]                      = CAST(NULL AS INT)
    ,[AcCTypeId]                      = CAST(NULL AS INT)
    ,[ChTypeId]                       = CAST(NULL AS INT)
    ,[BlTypeId]                       = CAST(NULL AS INT)
    ,[BlDimensionId]                  = CAST(NULL AS INT)
    ,[SpWidth]                        = CAST(NULL AS DECIMAL(9,2))
    ,[SpAspRatio]                     = CAST(NULL AS DECIMAL(9,2))
    ,[PackWidth]                      = CAST(NULL AS DECIMAL(9,2))
    ,[PackLength]                     = CAST(NULL AS DECIMAL(9,2))
    ,[PackHeight]                     = CAST(NULL AS DECIMAL(9,2))
    ,[WeightKg]                       = CAST(w.NetWeightKg AS DECIMAL(9,2))
    ,[WhWheelCod1]                    = CAST(NULL AS NCHAR(50))
    ,[WhWheelCod2]                    = CAST(NULL AS NCHAR(50))
    ,[TyEcoNoiseLev2]                 = CAST(NULL AS NVARCHAR(50))
FROM [WheelsNet].dbo.Wheels w
LEFT JOIN [WheelsNet].dbo.Brands b ON b.Id = w.BrandId

GO
