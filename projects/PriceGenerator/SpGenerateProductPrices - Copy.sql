USE [WheelSystems]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SpGenerateProductPrices]
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @cols NVARCHAR(MAX) = ''
	DECLARE @sql NVARCHAR(MAX) = ''

	-- Colonne dinamiche per ogni CustomerTypeId
	SELECT @cols = @cols
		+ ',[NetPriceInStock_' + CAST(CustomerTypeId AS VARCHAR(10)) + '] = ROUND(MAX(CASE WHEN CustomerTypeId = ' + CAST(CustomerTypeId AS VARCHAR(10)) + ' THEN NetPriceInStock END), 2)' + CHAR(13) + CHAR(10)
		+ ',[NetPriceOutStock_' + CAST(CustomerTypeId AS VARCHAR(10)) + '] = ROUND(MAX(CASE WHEN CustomerTypeId = ' + CAST(CustomerTypeId AS VARCHAR(10)) + ' THEN NetPriceOutStock END), 2)' + CHAR(13) + CHAR(10)
	FROM (SELECT DISTINCT CustomerTypeId FROM [dbo].[ProductPriceCustomerTypes]) x
	ORDER BY CustomerTypeId

	SET @sql = '
	;WITH PriceCalc AS (
		SELECT
			 ProductId = pr.Id
			,ListPrice = ISNULL(pr.ListPrice, 0)
			,BasePriceInStock = ISNULL(pr.BasePriceInStock, 0)
			,BasePriceOutStock = ISNULL(pr.BasePriceOutStock, 0)
			,ct.CustomerTypeId
			-- NetPriceInStock
			,NetPriceInStock = CASE
				-- Markup: BasePriceInStock > 0
				WHEN ISNULL(pr.BasePriceInStock, 0) > 0 THEN
					CASE pp_mu_in.ProductPriceTypeId
						WHEN 1 THEN pr.BasePriceInStock * (1.0 + pp_mu_in.PercSign * (ISNULL(mu_in.Perc1, 0) + ISNULL(mu_in.Perc2, 0)) / 100.0)
						WHEN 2 THEN pr.BasePriceInStock + pp_mu_in.PercSign * (ISNULL(mu_in.Perc1, 0) + ISNULL(mu_in.Perc2, 0))
						ELSE pr.BasePriceInStock
					END
				-- Discount: ListPrice > 0
				WHEN ISNULL(pr.ListPrice, 0) > 0 THEN
					CASE pp_disc_in.ProductPriceTypeId
						WHEN 1 THEN pr.ListPrice * (1.0 + pp_disc_in.PercSign * (ISNULL(disc_in.Perc1, 0) + ISNULL(disc_in.Perc2, 0)) / 100.0)
						WHEN 2 THEN pr.ListPrice + pp_disc_in.PercSign * (ISNULL(disc_in.Perc1, 0) + ISNULL(disc_in.Perc2, 0))
						ELSE 0
					END
				ELSE 0
			END
			-- NetPriceOutStock
			,NetPriceOutStock = CASE
				-- Markup: BasePriceOutStock > 0
				WHEN ISNULL(pr.BasePriceOutStock, 0) > 0 THEN
					CASE pp_mu_out.ProductPriceTypeId
						WHEN 1 THEN pr.BasePriceOutStock * (1.0 + pp_mu_out.PercSign * (ISNULL(mu_out.Perc1, 0) + ISNULL(mu_out.Perc2, 0)) / 100.0)
						WHEN 2 THEN pr.BasePriceOutStock + pp_mu_out.PercSign * (ISNULL(mu_out.Perc1, 0) + ISNULL(mu_out.Perc2, 0))
						ELSE pr.BasePriceOutStock
					END
				-- Discount: ListPrice > 0
				WHEN ISNULL(pr.ListPrice, 0) > 0 THEN
					CASE pp_disc_out.ProductPriceTypeId
						WHEN 1 THEN pr.ListPrice * (1.0 + pp_disc_out.PercSign * (ISNULL(disc_out.Perc1, 0) + ISNULL(disc_out.Perc2, 0)) / 100.0)
						WHEN 2 THEN pr.ListPrice + pp_disc_out.PercSign * (ISNULL(disc_out.Perc1, 0) + ISNULL(disc_out.Perc2, 0))
						ELSE 0
					END
				ELSE 0
			END
		FROM [dbo].[Products] pr
		CROSS JOIN (SELECT DISTINCT CustomerTypeId FROM [dbo].[ProductPriceCustomerTypes]) ct
		-- InStock MarkUp
		LEFT JOIN [dbo].[ProductPriceCustomerTypes] mu_in
			ON  mu_in.ProductPriceId = pr.InStockMarkUpProductPriceId
			AND mu_in.CustomerTypeId = ct.CustomerTypeId
		LEFT JOIN [dbo].[ProductPrices] pp_mu_in
			ON  pp_mu_in.Id = mu_in.ProductPriceId
		-- InStock Discount
		LEFT JOIN [dbo].[ProductPriceCustomerTypes] disc_in
			ON  disc_in.ProductPriceId = pr.InStockDiscountProductPriceId
			AND disc_in.CustomerTypeId = ct.CustomerTypeId
		LEFT JOIN [dbo].[ProductPrices] pp_disc_in
			ON  pp_disc_in.Id = disc_in.ProductPriceId
		-- OutStock MarkUp
		LEFT JOIN [dbo].[ProductPriceCustomerTypes] mu_out
			ON  mu_out.ProductPriceId = pr.OutStockMarkUpProductPriceId
			AND mu_out.CustomerTypeId = ct.CustomerTypeId
		LEFT JOIN [dbo].[ProductPrices] pp_mu_out
			ON  pp_mu_out.Id = mu_out.ProductPriceId
		-- OutStock Discount
		LEFT JOIN [dbo].[ProductPriceCustomerTypes] disc_out
			ON  disc_out.ProductPriceId = pr.OutStockDiscountProductPriceId
			AND disc_out.CustomerTypeId = ct.CustomerTypeId
		LEFT JOIN [dbo].[ProductPrices] pp_disc_out
			ON  pp_disc_out.Id = disc_out.ProductPriceId
	)
	SELECT
		 ProductId
		,ListPrice
		,BasePriceInStock
		,BasePriceOutStock
		' + @cols + '
	FROM PriceCalc
	GROUP BY
		 ProductId
		,ListPrice
		,BasePriceInStock
		,BasePriceOutStock
	'

	EXEC sp_executesql @sql
END
GO
