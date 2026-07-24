USE [WheelSystems]
GO

/****** Object:  View [dbo].[ViewProductPrices]    Script Date: 30/03/2026 20.27.37 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





--select * from ViewProductPrices where ProductId='CF00000520522' order by ProductId, CustomerTypeId
CREATE view [dbo].[ViewProductPrices]
as
WITH 
CteProductPrices AS (
    SELECT 
        [Id],
        [Descr],
        [PercSign],
        [ProductPriceTypeId]
    FROM [WheelSystems].[dbo].[ProductPrices]
),
CteProductPriceCustomerTypes AS (
    SELECT 
        [CustomerTypeId],
        [ProductPriceId],
        [ProductPriceDescr] = pp.Descr,
        pp.[ProductPriceTypeId], -- 1=Perc, 2=Euro
        pp.[PercSign],
        [Perc1],
        [Perc2]
    FROM [WheelSystems].[dbo].[ProductPriceCustomerTypes] ppct
    INNER JOIN CteProductPrices pp ON pp.Id = ppct.ProductPriceId
),
CteCustomerTypes AS (
    SELECT distinct
        [CustomerTypeId]
    FROM CteProductPriceCustomerTypes
),
CteProductStocks AS (
	SELECT
        ps.[ProductId],
        [InStock] =
            SUM(
                        CASE 
                            WHEN ps.WarehouseId <> 200 
                                THEN ISNULL(ps.AvailableStock, 0) + ISNULL(ps.OnArriveStock, 0)
                            ELSE 0
                        END
                    ),
		[OnDemandStock] =
            SUM(
                        CASE 
                            WHEN ps.WarehouseId = 200 
                                THEN ISNULL(ps.AvailableStock, 0) + ISNULL(ps.OnArriveStock, 0)
                            ELSE 0
                        END
                    ) 
    FROM [WheelSystems].[dbo].[ProductStocks] ps
    GROUP BY ps.[ProductId]
)
SELECT distinct
    [ProductId] = LTRIM(RTRIM(pr.Id)),
    [ProductTypeId]=pr.ProductTypeId,
    [Ean] = LTRIM(RTRIM(pr.EanCod)),
    [ListPrice] = ISNULL(pr.ListPrice, 0.00),
    [BasePriceInStock],
    [BasePriceOutStock],
    [CustomerTypeId] = ct.[CustomerTypeId],

    -- Discount
    [Disc_ProductPriceId] = InStockDiscCriteria.[ProductPriceId],
    [Disc_ProductPriceDescr] = InStockDiscCriteria.[ProductPriceDescr],
    [Disc_ProductPriceTypeId] = InStockDiscCriteria.[ProductPriceTypeId],
    [Disc_PercSign] = InStockDiscCriteria.[PercSign],
    [Disc_Perc1] = InStockDiscCriteria.[Perc1],
    [Disc_Perc2] = InStockDiscCriteria.[Perc2],

    -- MarkUp
    [MarkUp_ProductPriceId] = InStockMarkUpCriteria.[ProductPriceId],
    [MarkUp_ProductPriceDescr] = InStockMarkUpCriteria.[ProductPriceDescr],
    [MarkUp_ProductPriceTypeId] = InStockMarkUpCriteria.[ProductPriceTypeId],
    [MarkUp_PercSign] = InStockMarkUpCriteria.[PercSign],
    [MarkUp_Perc1] = InStockMarkUpCriteria.[Perc1],
    [MarkUp_Perc2] = InStockMarkUpCriteria.[Perc2],

    [InStock] = ISNULL(ps.[InStock], 0),
    [OnDemandStock] = ISNULL(ps.[OnDemandStock], 0)

FROM [WheelSystems].[dbo].[Products] pr
CROSS JOIN CteCustomerTypes ct 
INNER JOIN CteProductStocks ps ON ps.ProductId = pr.Id
LEFT JOIN CteProductPriceCustomerTypes InStockDiscCriteria 
    ON InStockDiscCriteria.ProductPriceId = pr.InStockDiscountProductPriceId and InStockDiscCriteria.CustomerTypeId=ct.CustomerTypeId
LEFT JOIN CteProductPriceCustomerTypes InStockMarkUpCriteria 
    ON InStockMarkUpCriteria.ProductPriceId = pr.InStockMarkUpProductPriceId and InStockMarkUpCriteria.CustomerTypeId=ct.CustomerTypeId
--LEFT JOIN CteProductPriceCustomerTypes OutStockDiscCriteria 
--    ON OutStockDiscCriteria.ProductPriceId = pr.OutStockDiscountProductPriceId and OutStockDiscCriteria.CustomerTypeId=ct.CustomerTypeId
--LEFT JOIN CteProductPriceCustomerTypes OutStockMarkUpCriteria 
--    ON OutStockMarkUpCriteria.ProductPriceId = pr.OutStockMarkUpProductPriceId and OutStockMarkUpCriteria.CustomerTypeId=ct.CustomerTypeId
--WHERE pr.Id = 'CF00000520522'
GO


