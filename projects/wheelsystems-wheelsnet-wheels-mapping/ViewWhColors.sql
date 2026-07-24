USE [WheelSystems]
GO

IF OBJECT_ID('dbo.ViewWhColors', 'V') IS NOT NULL
    DROP VIEW dbo.ViewWhColors
GO

/*
    ViewWhColors
    ------------
    WhColors originali
    UNION ALL
    WhColors sintetici derivati da [WheelsNet].dbo.Wheels (Color distinct)

    WhColor Id: 1999999 + DENSE_RANK() OVER (ORDER BY Color)

    Questa espressione DEVE essere identica a quella usata in ViewWhVersions
    per la valorizzazione di WhColorId nella Parte 2.
*/
CREATE VIEW dbo.ViewWhColors
AS

-- Parte 1: WhColors originali
SELECT
    [Id]
    ,[Descr]
FROM dbo.WhColors

UNION ALL

-- Parte 2: WhColors sintetici da Wheels
SELECT
    [Id]    = CAST(1999999 + DENSE_RANK() OVER (ORDER BY Color) AS INT)
    ,[Descr] = CAST(Color AS NVARCHAR(MAX))
FROM [WheelsNet].dbo.Wheels
GROUP BY Color

GO
