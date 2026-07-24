USE [WheelSystems]
GO

IF OBJECT_ID('dbo.ViewWhVersions', 'V') IS NOT NULL
    DROP VIEW dbo.ViewWhVersions
GO

/*
    ViewWhVersions
    --------------
    WhVersions originali usate da Products NON esclusi (TypeId NOT IN 2,3)
    UNION ALL
    WhVersions sintetiche derivate da [WheelsNet].dbo.Wheels

    Version Id:     1999999 + DENSE_RANK() OVER (ORDER BY BrandId, VersionCode, Holes, ColorCode)
    ProductModelId: 1999999 + DENSE_RANK() OVER (ORDER BY BrandId, Model, ProductTypeId)
    WhColorId:      1999999 + DENSE_RANK() OVER (ORDER BY Color)

    Queste espressioni DEVONO essere identiche in ViewProductModels, ViewProducts
    e ViewWhColors (per WhColorId).
*/
CREATE VIEW dbo.ViewWhVersions
AS

-- Parte 1: WhVersions originali (riferite a Products con TypeId NOT IN 2,3)
-- In pratica vuota: solo Products cerchi (TypeId 2,3) hanno WhVersionId valorizzato
SELECT
    wv.[Id]
    ,wv.[Cod]
    ,wv.[ProductModelId]
    ,wv.[Descr]
    ,wv.[Holes]
    ,wv.[WhColorId]
FROM dbo.WhVersions wv
WHERE EXISTS (
    SELECT 1
    FROM dbo.Products p
    WHERE p.WhVersionId = wv.Id
    AND p.ProductTypeId NOT IN (2, 3)
)

UNION ALL

-- Parte 2: WhVersions sintetiche da Wheels
SELECT
    [Id]             = CAST(w.VersionId AS INT)
    ,[Cod]           = w.VersionCode
    ,[ProductModelId] = CAST(w.ModelId AS INT)
    ,[Descr]         = CAST(w.[Version] AS NVARCHAR(MAX))
    ,[Holes]         = w.Holes
    ,[WhColorId]     = CAST(1999999 + DENSE_RANK() OVER (ORDER BY w.Color) AS INT)
FROM (
    SELECT
        VersionId    = 1999999 + DENSE_RANK() OVER (ORDER BY BrandId, VersionCode, Holes, ColorCode)
        ,ModelId     = 1999999 + DENSE_RANK() OVER (ORDER BY BrandId, Model, ProductTypeId)
        ,VersionCode = VersionCode
        ,[Version]   = [Version]
        ,Holes       = Holes
        ,ColorCode   = ColorCode
        ,Color       = MAX(Color)
    FROM [WheelsNet].dbo.Wheels
    GROUP BY BrandId, Model, ProductTypeId, VersionCode, [Version], Holes, ColorCode
) w

GO
