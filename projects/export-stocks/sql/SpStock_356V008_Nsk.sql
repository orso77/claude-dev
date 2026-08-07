/*

	Export stock/prezzi ruotini NSK per 356automotive.
	Ricalca [SpStock_356V001] filtrando p.BrandId = 1000001 (NSK).

	Differenze rispetto a V001 (tracciato richiesto da 356 - 356-NSK-stock.csv):
	- niente TrunkSizeCm / BoxSizeCm / NetWeightKg / GrossWeightKg in coda (13 colonne, fino a ProductDescr)
	- Price formattato 0.00 come gli altri numerici (V001 usa '0.##')

	+ 17 colonne aggiunte il 2026-08-07 da WheelsNet.dbo.Spares (tot 30):
	  Img1;Img2;Img3;Img4;Img5;Width;Diameter;Holes;Pcd1;MadeIn;NetWeightKg;
	  GrossWeightKg;MaxLoad;Tyre;BoxSize;Material;TrunkSize

	Cliente: 53001952 = NO STOP KIT SRL (titolare del brand NSK).
	CustomerTypeId 409 -> AutPrice08; ha Include=1 su BrandId NSK in AutContactProductExclusions.

	exec [SpStock_356V008_Nsk] @customerId = 53001952;

*/
USE [WheelSystemsExport];
GO

CREATE OR ALTER PROCEDURE [dbo].[SpStock_356V008_Nsk]
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
        ,Price               = dbo.FnDecimalFormat2(pp.NetPrice)                     -- 0.00 come gli altri numerici (V001 qui usa '0.##')
        ,IncomingStock15days = dbo.FnDecimalFormat2(ISNULL(s356.OnArriveStock,0) + ISNULL(s357.OnArriveStock,0))
        ,ManufacturerCod     = dbo.FnStringCleaner(p.ManufacturerCod)
        ,PfuId               = dbo.FnStringCleaner(nts.Id)
        ,PfuEuroNoVat        = dbo.FnDecimalFormat2(nts.NetPrice)
        ,Brand               = dbo.FnStringCleaner(b.Descr)
        ,ProductDescr        = dbo.FnStringCleaner(spr.Descr)
        ,Img1                = CASE WHEN spr.Img1 > '' THEN WheelsNet.dbo.FnUrlImg('356', 'large/' + spr.Img1) ELSE '' END
        ,Img2                = CASE WHEN spr.Img2 > '' THEN WheelsNet.dbo.FnUrlImg('356', 'large/' + spr.Img2) ELSE '' END
        ,Img3                = CASE WHEN spr.Img3 > '' THEN WheelsNet.dbo.FnUrlImg('356', 'large/' + spr.Img3) ELSE '' END
        ,Img4                = CASE WHEN spr.Img4 > '' THEN WheelsNet.dbo.FnUrlImg('356', 'large/' + spr.Img4) ELSE '' END
        ,Img5                = CASE WHEN spr.Img5 > '' THEN WheelsNet.dbo.FnUrlImg('356', 'large/' + spr.Img5) ELSE '' END
        ,Width               = dbo.FnDecimalFormat(spr.Width, '0.#', ',')
        ,Diameter            = dbo.FnDecimalFormat(spr.Diameter, '0.#', ',')
        ,Holes               = dbo.FnDecimalFormat(spr.Holes, '0', ',')
        ,Pcd1                = dbo.FnDecimalFormat(spr.Pcd1, '0.#', ',')
        ,MadeIn              = dbo.FnStringCleaner(spr.MadeIn)
        ,NetWeightKg         = dbo.FnDecimalFormat2(spr.NetWeightKg)
        ,GrossWeightKg       = dbo.FnDecimalFormat2(spr.GrossWeightKg)
        ,MaxLoad             = dbo.FnDecimalFormat(spr.MaxLoad, '0.#', ',')
        ,Tyre                = dbo.FnStringCleaner(spr.Tyre)
        ,BoxSize             = dbo.FnStringCleaner(spr.BoxSize)
        ,Material            = dbo.FnStringCleaner(spr.Material)
        ,TrunkSize           = dbo.FnStringCleaner(spr.TrunkSize)
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
        p.BrandId IN (1000001)                                                       -- NSK
    ORDER BY p.Id;
END
GO
