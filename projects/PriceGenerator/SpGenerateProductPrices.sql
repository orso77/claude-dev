USE [WheelsNet]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SpGenerateProductPrices]
AS
BEGIN
	SET NOCOUNT ON;

	DROP TABLE IF EXISTS #PriceCalc;

	CREATE TABLE #PriceCalc (
		 Source VARCHAR(3)
		,ProductId VARCHAR(50)
		,ListPrice DECIMAL(18,4)
		,CustomerTypeId INT
		,NetPriceInStock DECIMAL(18,4)
		,NetPriceOutStock DECIMAL(18,4)
	);

	----------------------------------------------------------------------
	-- TOP: [77.81.228.147].WheelSystems.dbo
	----------------------------------------------------------------------
	INSERT INTO #PriceCalc (Source, ProductId, ListPrice, CustomerTypeId, NetPriceInStock, NetPriceOutStock)
	SELECT
		 'TOP'
		,pr.Id
		,ISNULL(pr.ListPrice, 0)
		,ct.CustomerTypeId
		,NetPriceInStock = CASE
			WHEN ISNULL(pr.BasePriceInStock, 0) > 0 THEN
				CASE pp_mu_in.ProductPriceTypeId
					WHEN 1 THEN pr.BasePriceInStock * (1.0 + pp_mu_in.PercSign * (ISNULL(mu_in.Perc1, 0) + ISNULL(mu_in.Perc2, 0)) / 100.0)
					WHEN 2 THEN pr.BasePriceInStock + pp_mu_in.PercSign * (ISNULL(mu_in.Perc1, 0) + ISNULL(mu_in.Perc2, 0))
					ELSE pr.BasePriceInStock
				END
			WHEN ISNULL(pr.ListPrice, 0) > 0 THEN
				CASE pp_disc_in.ProductPriceTypeId
					WHEN 1 THEN pr.ListPrice * (1.0 + pp_disc_in.PercSign * (ISNULL(disc_in.Perc1, 0) + ISNULL(disc_in.Perc2, 0)) / 100.0)
					WHEN 2 THEN pr.ListPrice + pp_disc_in.PercSign * (ISNULL(disc_in.Perc1, 0) + ISNULL(disc_in.Perc2, 0))
					ELSE 0
				END
			ELSE 0
		END
		,NetPriceOutStock = CASE
			WHEN ISNULL(pr.BasePriceOutStock, 0) > 0 THEN
				CASE pp_mu_out.ProductPriceTypeId
					WHEN 1 THEN pr.BasePriceOutStock * (1.0 + pp_mu_out.PercSign * (ISNULL(mu_out.Perc1, 0) + ISNULL(mu_out.Perc2, 0)) / 100.0)
					WHEN 2 THEN pr.BasePriceOutStock + pp_mu_out.PercSign * (ISNULL(mu_out.Perc1, 0) + ISNULL(mu_out.Perc2, 0))
					ELSE pr.BasePriceOutStock
				END
			WHEN ISNULL(pr.ListPrice, 0) > 0 THEN
				CASE pp_disc_out.ProductPriceTypeId
					WHEN 1 THEN pr.ListPrice * (1.0 + pp_disc_out.PercSign * (ISNULL(disc_out.Perc1, 0) + ISNULL(disc_out.Perc2, 0)) / 100.0)
					WHEN 2 THEN pr.ListPrice + pp_disc_out.PercSign * (ISNULL(disc_out.Perc1, 0) + ISNULL(disc_out.Perc2, 0))
					ELSE 0
				END
			ELSE 0
		END
	FROM [77.81.228.147].WheelSystems.dbo.Products pr
	CROSS JOIN (SELECT DISTINCT CustomerTypeId FROM [77.81.228.147].WheelSystems.dbo.ProductPriceCustomerTypes) ct
	LEFT JOIN [77.81.228.147].WheelSystems.dbo.ProductPriceCustomerTypes mu_in
		ON  mu_in.ProductPriceId = pr.InStockMarkUpProductPriceId AND mu_in.CustomerTypeId = ct.CustomerTypeId
	LEFT JOIN [77.81.228.147].WheelSystems.dbo.ProductPrices pp_mu_in
		ON  pp_mu_in.Id = mu_in.ProductPriceId
	LEFT JOIN [77.81.228.147].WheelSystems.dbo.ProductPriceCustomerTypes disc_in
		ON  disc_in.ProductPriceId = pr.InStockDiscountProductPriceId AND disc_in.CustomerTypeId = ct.CustomerTypeId
	LEFT JOIN [77.81.228.147].WheelSystems.dbo.ProductPrices pp_disc_in
		ON  pp_disc_in.Id = disc_in.ProductPriceId
	LEFT JOIN [77.81.228.147].WheelSystems.dbo.ProductPriceCustomerTypes mu_out
		ON  mu_out.ProductPriceId = pr.OutStockMarkUpProductPriceId AND mu_out.CustomerTypeId = ct.CustomerTypeId
	LEFT JOIN [77.81.228.147].WheelSystems.dbo.ProductPrices pp_mu_out
		ON  pp_mu_out.Id = mu_out.ProductPriceId
	LEFT JOIN [77.81.228.147].WheelSystems.dbo.ProductPriceCustomerTypes disc_out
		ON  disc_out.ProductPriceId = pr.OutStockDiscountProductPriceId AND disc_out.CustomerTypeId = ct.CustomerTypeId
	LEFT JOIN [77.81.228.147].WheelSystems.dbo.ProductPrices pp_disc_out
		ON  pp_disc_out.Id = disc_out.ProductPriceId;

	----------------------------------------------------------------------
	-- AUT: [77.81.228.147].WheelSystems356.dbo
	----------------------------------------------------------------------
	INSERT INTO #PriceCalc (Source, ProductId, ListPrice, CustomerTypeId, NetPriceInStock, NetPriceOutStock)
	SELECT
		 'AUT'
		,pr.Id
		,ISNULL(pr.ListPrice, 0)
		,ct.CustomerTypeId
		,NetPriceInStock = CASE
			WHEN ISNULL(pr.BasePriceInStock, 0) > 0 THEN
				CASE pp_mu_in.ProductPriceTypeId
					WHEN 1 THEN pr.BasePriceInStock * (1.0 + pp_mu_in.PercSign * (ISNULL(mu_in.Perc1, 0) + ISNULL(mu_in.Perc2, 0)) / 100.0)
					WHEN 2 THEN pr.BasePriceInStock + pp_mu_in.PercSign * (ISNULL(mu_in.Perc1, 0) + ISNULL(mu_in.Perc2, 0))
					ELSE pr.BasePriceInStock
				END
			WHEN ISNULL(pr.ListPrice, 0) > 0 THEN
				CASE pp_disc_in.ProductPriceTypeId
					WHEN 1 THEN pr.ListPrice * (1.0 + pp_disc_in.PercSign * (ISNULL(disc_in.Perc1, 0) + ISNULL(disc_in.Perc2, 0)) / 100.0)
					WHEN 2 THEN pr.ListPrice + pp_disc_in.PercSign * (ISNULL(disc_in.Perc1, 0) + ISNULL(disc_in.Perc2, 0))
					ELSE 0
				END
			ELSE 0
		END
		,NetPriceOutStock = CASE
			WHEN ISNULL(pr.BasePriceOutStock, 0) > 0 THEN
				CASE pp_mu_out.ProductPriceTypeId
					WHEN 1 THEN pr.BasePriceOutStock * (1.0 + pp_mu_out.PercSign * (ISNULL(mu_out.Perc1, 0) + ISNULL(mu_out.Perc2, 0)) / 100.0)
					WHEN 2 THEN pr.BasePriceOutStock + pp_mu_out.PercSign * (ISNULL(mu_out.Perc1, 0) + ISNULL(mu_out.Perc2, 0))
					ELSE pr.BasePriceOutStock
				END
			WHEN ISNULL(pr.ListPrice, 0) > 0 THEN
				CASE pp_disc_out.ProductPriceTypeId
					WHEN 1 THEN pr.ListPrice * (1.0 + pp_disc_out.PercSign * (ISNULL(disc_out.Perc1, 0) + ISNULL(disc_out.Perc2, 0)) / 100.0)
					WHEN 2 THEN pr.ListPrice + pp_disc_out.PercSign * (ISNULL(disc_out.Perc1, 0) + ISNULL(disc_out.Perc2, 0))
					ELSE 0
				END
			ELSE 0
		END
	FROM [77.81.228.147].WheelSystems356.dbo.Products pr
	CROSS JOIN (SELECT DISTINCT CustomerTypeId FROM [77.81.228.147].WheelSystems356.dbo.ProductPriceCustomerTypes) ct
	LEFT JOIN [77.81.228.147].WheelSystems356.dbo.ProductPriceCustomerTypes mu_in
		ON  mu_in.ProductPriceId = pr.InStockMarkUpProductPriceId AND mu_in.CustomerTypeId = ct.CustomerTypeId
	LEFT JOIN [77.81.228.147].WheelSystems356.dbo.ProductPrices pp_mu_in
		ON  pp_mu_in.Id = mu_in.ProductPriceId
	LEFT JOIN [77.81.228.147].WheelSystems356.dbo.ProductPriceCustomerTypes disc_in
		ON  disc_in.ProductPriceId = pr.InStockDiscountProductPriceId AND disc_in.CustomerTypeId = ct.CustomerTypeId
	LEFT JOIN [77.81.228.147].WheelSystems356.dbo.ProductPrices pp_disc_in
		ON  pp_disc_in.Id = disc_in.ProductPriceId
	LEFT JOIN [77.81.228.147].WheelSystems356.dbo.ProductPriceCustomerTypes mu_out
		ON  mu_out.ProductPriceId = pr.OutStockMarkUpProductPriceId AND mu_out.CustomerTypeId = ct.CustomerTypeId
	LEFT JOIN [77.81.228.147].WheelSystems356.dbo.ProductPrices pp_mu_out
		ON  pp_mu_out.Id = mu_out.ProductPriceId
	LEFT JOIN [77.81.228.147].WheelSystems356.dbo.ProductPriceCustomerTypes disc_out
		ON  disc_out.ProductPriceId = pr.OutStockDiscountProductPriceId AND disc_out.CustomerTypeId = ct.CustomerTypeId
	LEFT JOIN [77.81.228.147].WheelSystems356.dbo.ProductPrices pp_disc_out
		ON  pp_disc_out.Id = disc_out.ProductPriceId;

	----------------------------------------------------------------------
	-- REV: WheelSystemsRevorim.dbo
	----------------------------------------------------------------------
	INSERT INTO #PriceCalc (Source, ProductId, ListPrice, CustomerTypeId, NetPriceInStock, NetPriceOutStock)
	SELECT
		 'REV'
		,pr.Id
		,ISNULL(pr.ListPrice, 0)
		,ct.CustomerTypeId
		,NetPriceInStock = CASE
			WHEN ISNULL(pr.BasePriceInStock, 0) > 0 THEN
				CASE pp_mu_in.ProductPriceTypeId
					WHEN 1 THEN pr.BasePriceInStock * (1.0 + pp_mu_in.PercSign * (ISNULL(mu_in.Perc1, 0) + ISNULL(mu_in.Perc2, 0)) / 100.0)
					WHEN 2 THEN pr.BasePriceInStock + pp_mu_in.PercSign * (ISNULL(mu_in.Perc1, 0) + ISNULL(mu_in.Perc2, 0))
					ELSE pr.BasePriceInStock
				END
			WHEN ISNULL(pr.ListPrice, 0) > 0 THEN
				CASE pp_disc_in.ProductPriceTypeId
					WHEN 1 THEN pr.ListPrice * (1.0 + pp_disc_in.PercSign * (ISNULL(disc_in.Perc1, 0) + ISNULL(disc_in.Perc2, 0)) / 100.0)
					WHEN 2 THEN pr.ListPrice + pp_disc_in.PercSign * (ISNULL(disc_in.Perc1, 0) + ISNULL(disc_in.Perc2, 0))
					ELSE 0
				END
			ELSE 0
		END
		,NetPriceOutStock = CASE
			WHEN ISNULL(pr.BasePriceOutStock, 0) > 0 THEN
				CASE pp_mu_out.ProductPriceTypeId
					WHEN 1 THEN pr.BasePriceOutStock * (1.0 + pp_mu_out.PercSign * (ISNULL(mu_out.Perc1, 0) + ISNULL(mu_out.Perc2, 0)) / 100.0)
					WHEN 2 THEN pr.BasePriceOutStock + pp_mu_out.PercSign * (ISNULL(mu_out.Perc1, 0) + ISNULL(mu_out.Perc2, 0))
					ELSE pr.BasePriceOutStock
				END
			WHEN ISNULL(pr.ListPrice, 0) > 0 THEN
				CASE pp_disc_out.ProductPriceTypeId
					WHEN 1 THEN pr.ListPrice * (1.0 + pp_disc_out.PercSign * (ISNULL(disc_out.Perc1, 0) + ISNULL(disc_out.Perc2, 0)) / 100.0)
					WHEN 2 THEN pr.ListPrice + pp_disc_out.PercSign * (ISNULL(disc_out.Perc1, 0) + ISNULL(disc_out.Perc2, 0))
					ELSE 0
				END
			ELSE 0
		END
	FROM WheelSystemsRevorim.dbo.Products pr
	CROSS JOIN (SELECT DISTINCT CustomerTypeId FROM WheelSystemsRevorim.dbo.ProductPriceCustomerTypes) ct
	LEFT JOIN WheelSystemsRevorim.dbo.ProductPriceCustomerTypes mu_in
		ON  mu_in.ProductPriceId = pr.InStockMarkUpProductPriceId AND mu_in.CustomerTypeId = ct.CustomerTypeId
	LEFT JOIN WheelSystemsRevorim.dbo.ProductPrices pp_mu_in
		ON  pp_mu_in.Id = mu_in.ProductPriceId
	LEFT JOIN WheelSystemsRevorim.dbo.ProductPriceCustomerTypes disc_in
		ON  disc_in.ProductPriceId = pr.InStockDiscountProductPriceId AND disc_in.CustomerTypeId = ct.CustomerTypeId
	LEFT JOIN WheelSystemsRevorim.dbo.ProductPrices pp_disc_in
		ON  pp_disc_in.Id = disc_in.ProductPriceId
	LEFT JOIN WheelSystemsRevorim.dbo.ProductPriceCustomerTypes mu_out
		ON  mu_out.ProductPriceId = pr.OutStockMarkUpProductPriceId AND mu_out.CustomerTypeId = ct.CustomerTypeId
	LEFT JOIN WheelSystemsRevorim.dbo.ProductPrices pp_mu_out
		ON  pp_mu_out.Id = mu_out.ProductPriceId
	LEFT JOIN WheelSystemsRevorim.dbo.ProductPriceCustomerTypes disc_out
		ON  disc_out.ProductPriceId = pr.OutStockDiscountProductPriceId AND disc_out.CustomerTypeId = ct.CustomerTypeId
	LEFT JOIN WheelSystemsRevorim.dbo.ProductPrices pp_disc_out
		ON  pp_disc_out.Id = disc_out.ProductPriceId;

	----------------------------------------------------------------------
	-- Pivot e INSERT nella tabella destinazione
	----------------------------------------------------------------------
	-- Mapping:
	-- TOP: 2→01, 3→02, 4→03, 5→04, 6→05, 7→06, 8→07, 9→08, 501→09, 11→10
	-- AUT: 402→01, 403→02, 404→03, 405→04, 406→05, 407→06, 408→07, 409→08, 501→09, 411→10
	-- REV: 2→01, 3→02, 4→03, 5→04, 6→05, 7→06, 8→07, 9→08, 10→09, 11→10

	TRUNCATE TABLE [dbo].[ProductPrices];

	INSERT INTO [dbo].[ProductPrices] (
		 [ProductId]
		,[ListPrice]
		,[TopPrice01In],[TopPrice01Out]
		,[TopPrice02In],[TopPrice02Out]
		,[TopPrice03In],[TopPrice03Out]
		,[TopPrice04In],[TopPrice04Out]
		,[TopPrice05In],[TopPrice05Out]
		,[TopPrice06In],[TopPrice06Out]
		,[TopPrice07In],[TopPrice07Out]
		,[TopPrice08In],[TopPrice08Out]
		,[TopPrice09In],[TopPrice09Out]
		,[TopPrice10In],[TopPrice10Out]
		,[RevPrice01In],[RevPrice01Out]
		,[RevPrice02In],[RevPrice02Out]
		,[RevPrice03In],[RevPrice03Out]
		,[RevPrice04In],[RevPrice04Out]
		,[RevPrice05In],[RevPrice05Out]
		,[RevPrice06In],[RevPrice06Out]
		,[RevPrice07In],[RevPrice07Out]
		,[RevPrice08In],[RevPrice08Out]
		,[RevPrice09In],[RevPrice09Out]
		,[RevPrice10In],[RevPrice10Out]
		,[AutPrice01In],[AutPrice01Out]
		,[AutPrice02In],[AutPrice02Out]
		,[AutPrice03In],[AutPrice03Out]
		,[AutPrice04In],[AutPrice04Out]
		,[AutPrice05In],[AutPrice05Out]
		,[AutPrice06In],[AutPrice06Out]
		,[AutPrice07In],[AutPrice07Out]
		,[AutPrice08In],[AutPrice08Out]
		,[AutPrice09In],[AutPrice09Out]
		,[AutPrice10In],[AutPrice10Out]
		,[Timestamp]
	)
	SELECT
		 ProductId
		,[ListPrice] = MAX(ListPrice)
		-- TOP: 2→01, 3→02, 4→03, 5→04, 6→05, 7→06, 8→07, 9→08, 501→09, 11→10
		,[TopPrice01In]  = ISNULL(ROUND(MAX(CASE WHEN Source = 'TOP' AND CustomerTypeId = 2   THEN NetPriceInStock  END), 4), 0)
		,[TopPrice01Out] = ISNULL(ROUND(MAX(CASE WHEN Source = 'TOP' AND CustomerTypeId = 2   THEN NetPriceOutStock END), 4), 0)
		,[TopPrice02In]  = ISNULL(ROUND(MAX(CASE WHEN Source = 'TOP' AND CustomerTypeId = 3   THEN NetPriceInStock  END), 4), 0)
		,[TopPrice02Out] = ISNULL(ROUND(MAX(CASE WHEN Source = 'TOP' AND CustomerTypeId = 3   THEN NetPriceOutStock END), 4), 0)
		,[TopPrice03In]  = ISNULL(ROUND(MAX(CASE WHEN Source = 'TOP' AND CustomerTypeId = 4   THEN NetPriceInStock  END), 4), 0)
		,[TopPrice03Out] = ISNULL(ROUND(MAX(CASE WHEN Source = 'TOP' AND CustomerTypeId = 4   THEN NetPriceOutStock END), 4), 0)
		,[TopPrice04In]  = ISNULL(ROUND(MAX(CASE WHEN Source = 'TOP' AND CustomerTypeId = 5   THEN NetPriceInStock  END), 4), 0)
		,[TopPrice04Out] = ISNULL(ROUND(MAX(CASE WHEN Source = 'TOP' AND CustomerTypeId = 5   THEN NetPriceOutStock END), 4), 0)
		,[TopPrice05In]  = ISNULL(ROUND(MAX(CASE WHEN Source = 'TOP' AND CustomerTypeId = 6   THEN NetPriceInStock  END), 4), 0)
		,[TopPrice05Out] = ISNULL(ROUND(MAX(CASE WHEN Source = 'TOP' AND CustomerTypeId = 6   THEN NetPriceOutStock END), 4), 0)
		,[TopPrice06In]  = ISNULL(ROUND(MAX(CASE WHEN Source = 'TOP' AND CustomerTypeId = 7   THEN NetPriceInStock  END), 4), 0)
		,[TopPrice06Out] = ISNULL(ROUND(MAX(CASE WHEN Source = 'TOP' AND CustomerTypeId = 7   THEN NetPriceOutStock END), 4), 0)
		,[TopPrice07In]  = ISNULL(ROUND(MAX(CASE WHEN Source = 'TOP' AND CustomerTypeId = 8   THEN NetPriceInStock  END), 4), 0)
		,[TopPrice07Out] = ISNULL(ROUND(MAX(CASE WHEN Source = 'TOP' AND CustomerTypeId = 8   THEN NetPriceOutStock END), 4), 0)
		,[TopPrice08In]  = ISNULL(ROUND(MAX(CASE WHEN Source = 'TOP' AND CustomerTypeId = 9   THEN NetPriceInStock  END), 4), 0)
		,[TopPrice08Out] = ISNULL(ROUND(MAX(CASE WHEN Source = 'TOP' AND CustomerTypeId = 9   THEN NetPriceOutStock END), 4), 0)
		,[TopPrice09In]  = ISNULL(ROUND(MAX(CASE WHEN Source = 'TOP' AND CustomerTypeId = 501 THEN NetPriceInStock  END), 4), 0)
		,[TopPrice09Out] = ISNULL(ROUND(MAX(CASE WHEN Source = 'TOP' AND CustomerTypeId = 501 THEN NetPriceOutStock END), 4), 0)
		,[TopPrice10In]  = ISNULL(ROUND(MAX(CASE WHEN Source = 'TOP' AND CustomerTypeId = 11  THEN NetPriceInStock  END), 4), 0)
		,[TopPrice10Out] = ISNULL(ROUND(MAX(CASE WHEN Source = 'TOP' AND CustomerTypeId = 11  THEN NetPriceOutStock END), 4), 0)
		-- REV: 2→01, 3→02, 4→03, 5→04, 6→05, 7→06, 8→07, 9→08, 10→09, 11→10
		,[RevPrice01In]  = ISNULL(ROUND(MAX(CASE WHEN Source = 'REV' AND CustomerTypeId = 2   THEN NetPriceInStock  END), 4), 0)
		,[RevPrice01Out] = ISNULL(ROUND(MAX(CASE WHEN Source = 'REV' AND CustomerTypeId = 2   THEN NetPriceOutStock END), 4), 0)
		,[RevPrice02In]  = ISNULL(ROUND(MAX(CASE WHEN Source = 'REV' AND CustomerTypeId = 3   THEN NetPriceInStock  END), 4), 0)
		,[RevPrice02Out] = ISNULL(ROUND(MAX(CASE WHEN Source = 'REV' AND CustomerTypeId = 3   THEN NetPriceOutStock END), 4), 0)
		,[RevPrice03In]  = ISNULL(ROUND(MAX(CASE WHEN Source = 'REV' AND CustomerTypeId = 4   THEN NetPriceInStock  END), 4), 0)
		,[RevPrice03Out] = ISNULL(ROUND(MAX(CASE WHEN Source = 'REV' AND CustomerTypeId = 4   THEN NetPriceOutStock END), 4), 0)
		,[RevPrice04In]  = ISNULL(ROUND(MAX(CASE WHEN Source = 'REV' AND CustomerTypeId = 5   THEN NetPriceInStock  END), 4), 0)
		,[RevPrice04Out] = ISNULL(ROUND(MAX(CASE WHEN Source = 'REV' AND CustomerTypeId = 5   THEN NetPriceOutStock END), 4), 0)
		,[RevPrice05In]  = ISNULL(ROUND(MAX(CASE WHEN Source = 'REV' AND CustomerTypeId = 6   THEN NetPriceInStock  END), 4), 0)
		,[RevPrice05Out] = ISNULL(ROUND(MAX(CASE WHEN Source = 'REV' AND CustomerTypeId = 6   THEN NetPriceOutStock END), 4), 0)
		,[RevPrice06In]  = ISNULL(ROUND(MAX(CASE WHEN Source = 'REV' AND CustomerTypeId = 7   THEN NetPriceInStock  END), 4), 0)
		,[RevPrice06Out] = ISNULL(ROUND(MAX(CASE WHEN Source = 'REV' AND CustomerTypeId = 7   THEN NetPriceOutStock END), 4), 0)
		,[RevPrice07In]  = ISNULL(ROUND(MAX(CASE WHEN Source = 'REV' AND CustomerTypeId = 8   THEN NetPriceInStock  END), 4), 0)
		,[RevPrice07Out] = ISNULL(ROUND(MAX(CASE WHEN Source = 'REV' AND CustomerTypeId = 8   THEN NetPriceOutStock END), 4), 0)
		,[RevPrice08In]  = ISNULL(ROUND(MAX(CASE WHEN Source = 'REV' AND CustomerTypeId = 9   THEN NetPriceInStock  END), 4), 0)
		,[RevPrice08Out] = ISNULL(ROUND(MAX(CASE WHEN Source = 'REV' AND CustomerTypeId = 9   THEN NetPriceOutStock END), 4), 0)
		,[RevPrice09In]  = ISNULL(ROUND(MAX(CASE WHEN Source = 'REV' AND CustomerTypeId = 10  THEN NetPriceInStock  END), 4), 0)
		,[RevPrice09Out] = ISNULL(ROUND(MAX(CASE WHEN Source = 'REV' AND CustomerTypeId = 10  THEN NetPriceOutStock END), 4), 0)
		,[RevPrice10In]  = ISNULL(ROUND(MAX(CASE WHEN Source = 'REV' AND CustomerTypeId = 11  THEN NetPriceInStock  END), 4), 0)
		,[RevPrice10Out] = ISNULL(ROUND(MAX(CASE WHEN Source = 'REV' AND CustomerTypeId = 11  THEN NetPriceOutStock END), 4), 0)
		-- AUT: 402→01, 403→02, 404→03, 405→04, 406→05, 407→06, 408→07, 409→08, 501→09, 411→10
		,[AutPrice01In]  = ISNULL(ROUND(MAX(CASE WHEN Source = 'AUT' AND CustomerTypeId = 402 THEN NetPriceInStock  END), 4), 0)
		,[AutPrice01Out] = ISNULL(ROUND(MAX(CASE WHEN Source = 'AUT' AND CustomerTypeId = 402 THEN NetPriceOutStock END), 4), 0)
		,[AutPrice02In]  = ISNULL(ROUND(MAX(CASE WHEN Source = 'AUT' AND CustomerTypeId = 403 THEN NetPriceInStock  END), 4), 0)
		,[AutPrice02Out] = ISNULL(ROUND(MAX(CASE WHEN Source = 'AUT' AND CustomerTypeId = 403 THEN NetPriceOutStock END), 4), 0)
		,[AutPrice03In]  = ISNULL(ROUND(MAX(CASE WHEN Source = 'AUT' AND CustomerTypeId = 404 THEN NetPriceInStock  END), 4), 0)
		,[AutPrice03Out] = ISNULL(ROUND(MAX(CASE WHEN Source = 'AUT' AND CustomerTypeId = 404 THEN NetPriceOutStock END), 4), 0)
		,[AutPrice04In]  = ISNULL(ROUND(MAX(CASE WHEN Source = 'AUT' AND CustomerTypeId = 405 THEN NetPriceInStock  END), 4), 0)
		,[AutPrice04Out] = ISNULL(ROUND(MAX(CASE WHEN Source = 'AUT' AND CustomerTypeId = 405 THEN NetPriceOutStock END), 4), 0)
		,[AutPrice05In]  = ISNULL(ROUND(MAX(CASE WHEN Source = 'AUT' AND CustomerTypeId = 406 THEN NetPriceInStock  END), 4), 0)
		,[AutPrice05Out] = ISNULL(ROUND(MAX(CASE WHEN Source = 'AUT' AND CustomerTypeId = 406 THEN NetPriceOutStock END), 4), 0)
		,[AutPrice06In]  = ISNULL(ROUND(MAX(CASE WHEN Source = 'AUT' AND CustomerTypeId = 407 THEN NetPriceInStock  END), 4), 0)
		,[AutPrice06Out] = ISNULL(ROUND(MAX(CASE WHEN Source = 'AUT' AND CustomerTypeId = 407 THEN NetPriceOutStock END), 4), 0)
		,[AutPrice07In]  = ISNULL(ROUND(MAX(CASE WHEN Source = 'AUT' AND CustomerTypeId = 408 THEN NetPriceInStock  END), 4), 0)
		,[AutPrice07Out] = ISNULL(ROUND(MAX(CASE WHEN Source = 'AUT' AND CustomerTypeId = 408 THEN NetPriceOutStock END), 4), 0)
		,[AutPrice08In]  = ISNULL(ROUND(MAX(CASE WHEN Source = 'AUT' AND CustomerTypeId = 409 THEN NetPriceInStock  END), 4), 0)
		,[AutPrice08Out] = ISNULL(ROUND(MAX(CASE WHEN Source = 'AUT' AND CustomerTypeId = 409 THEN NetPriceOutStock END), 4), 0)
		,[AutPrice09In]  = ISNULL(ROUND(MAX(CASE WHEN Source = 'AUT' AND CustomerTypeId = 501 THEN NetPriceInStock  END), 4), 0)
		,[AutPrice09Out] = ISNULL(ROUND(MAX(CASE WHEN Source = 'AUT' AND CustomerTypeId = 501 THEN NetPriceOutStock END), 4), 0)
		,[AutPrice10In]  = ISNULL(ROUND(MAX(CASE WHEN Source = 'AUT' AND CustomerTypeId = 411 THEN NetPriceInStock  END), 4), 0)
		,[AutPrice10Out] = ISNULL(ROUND(MAX(CASE WHEN Source = 'AUT' AND CustomerTypeId = 411 THEN NetPriceOutStock END), 4), 0)
		,[Timestamp] = GETDATE()
	FROM #PriceCalc
	GROUP BY ProductId;

	DROP TABLE IF EXISTS #PriceCalc;
END
GO
