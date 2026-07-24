/* =============================================================================
   WheelSystemsExport.dbo.SpStock_356V001
   Export stock "356 spare wheels" per cliente, modalita' revorim (SqlToFile).
   Riproduce il tracciato standard a 17 colonne dei vecchi file View356Stock:
     ProductId;Ean;Stock1;Stock2;Currency;ListPrice;Price;IncomingStock15days;
     ManufacturerCod;PfuId;PfuEuroNoVat;Brand;ProductDescr;TrunkSizeCm;BoxSizeCm;
     NetWeightKg;GrossWeightKg
   Il sottoinsieme prodotti per cliente NON e' un filtro brand fisso: e' dato dai
   prodotti prezzati per il cliente (INNER JOIN sul result set di SpAutPriceSpares
   con @includeZeroNetPrice=0). Il WHERE limita solo all'universo 356 (348/349/380).

   exec dbo.SpStock_356V001 53000522           -- 4s
   exec dbo.SpStock_356V001 53000522, 'RU000KOE0001S'
   ============================================================================= */
USE [WheelSystemsExport];
GO

CREATE OR ALTER PROCEDURE [dbo].[SpStock_356V001]
    @customerId INT,
    @productId  varchar(50) = null
AS
BEGIN
    SET NOCOUNT ON;

    -- Prezzi netti / stock per cliente. Result set a 16 colonne:
    -- come il template revorim (#ProductPricesTemp) + MissingPrice in coda.
    CREATE TABLE #pp
    (
        ProductId           varchar(50),
        ProductTypeId       int,
        BrandId             varchar(50),
        ListPrice           decimal(18,4),
        DiscPerc1Original   decimal(18,4),
        NetPriceOriginal    decimal(18,4),
        InStock             bit,
        IsEuro              bit,
        DiscValue           decimal(18,4),
        DiscPerc1           decimal(18,4),
        DiscPerc2           decimal(18,4),
        NetPrice            decimal(18,4),
        AvailStock          decimal(18,4),
        OnArriveStock       decimal(18,4),
        OnDemandStock       decimal(18,4),
        MissingPrice        bit
    );

    INSERT INTO #pp
    EXEC WheelsNet.dbo.SpAutPriceSpares
         @contactId          = @customerId
        ,@productId          = @productId
        ,@includeZeroNetPrice = 0;

    SELECT
         ProductId           = dbo.FnStringCleaner(p.Id)
        ,Ean                 = dbo.FnStringCleaner(p.EanCod)
        ,Stock1              = dbo.FnDecimalFormat2(CASE WHEN ISNULL(s356.AvailableStock,0) <= 0 THEN 0 WHEN s356.AvailableStock > 40 THEN 40 ELSE s356.AvailableStock END)
        ,Stock2              = dbo.FnDecimalFormat2(CASE WHEN ISNULL(s357.AvailableStock,0) <= 0 THEN 0 WHEN s357.AvailableStock > 40 THEN 40 ELSE s357.AvailableStock END)
        ,Currency            = 'EUR'
        ,ListPrice           = dbo.FnDecimalFormat2(pp.ListPrice)
        ,Price               = dbo.FnDecimalFormat(pp.NetPrice, '0.##', ',')
        ,IncomingStock15days = dbo.FnDecimalFormat2(ISNULL(s356.OnArriveStock,0) + ISNULL(s357.OnArriveStock,0))
        ,ManufacturerCod     = dbo.FnStringCleaner(p.ManufacturerCod)
        ,PfuId               = dbo.FnStringCleaner(nts.Id)
        ,PfuEuroNoVat        = dbo.FnDecimalFormat2(nts.NetPrice)
        ,Brand               = dbo.FnStringCleaner(b.Descr)
        ,ProductDescr        = dbo.FnStringCleaner(spr.Descr)
        ,TrunkSizeCm         = dbo.FnStringCleaner(spr.TrunkSize)
        ,BoxSizeCm           = dbo.FnStringCleaner(spr.BoxSize)
        ,NetWeightKg         = dbo.FnDecimalFormat2(spr.NetWeightKg)
        ,GrossWeightKg       = dbo.FnDecimalFormat2(spr.GrossWeightKg)
    FROM WheelSystemsAutomotive.dbo.Products p
    INNER JOIN #pp pp
        ON pp.ProductId = p.Id COLLATE Latin1_General_CI_AS                          -- solo prodotti prezzati per il cliente
    INNER JOIN WheelSystemsAutomotive.dbo.Brands b
        ON b.Id = p.BrandId
    LEFT JOIN WheelsNet.dbo.Spares spr
        ON spr.Id = p.Id COLLATE Latin1_General_CI_AS
    LEFT JOIN WheelSystemsAutomotive.dbo.ProductStocks s356
        ON s356.ProductId = p.Id AND s356.WarehouseId = 356
    LEFT JOIN WheelSystemsAutomotive.dbo.ProductStocks s357
        ON s357.ProductId = p.Id AND s357.WarehouseId = 357
    LEFT JOIN WheelSystemsAutomotive.dbo.NtsProducts nts
        ON nts.Id = 'PFUGT02'
    WHERE
        p.BrandId IN (348, 349, 380)                                                 -- universo 356: NUVOLARI / 356 SPARE WHEELS / BASIC
    ORDER BY p.Id;
END
GO
