USE [replicaTopRuote]
GO
/*
select count(*) from Wheels
select count(*) from Wheels_Src
*/
create or alter view dbo.Wheels_Src
as
/*
SELECT [Id]
      ,[SmallImgUrl]
      ,[MediumImgUrl]
      ,[LargeImgUrl]
      ,[Descr]
      ,[LastPurchPrice]
      ,[EanCod]
      ,[VehicleTypes]
      ,[WhWidth]
      ,[Diameter]
      ,[WhOffset]
      ,[WhPcd1]
      ,[WhPcd2]
      ,[WhPcd3]
      ,[WhMinBoreDiam]
      ,[WhMaxBoreDiam]
      ,[WhIntHeft]
      ,[WhExtHeft]
      ,[Brand]
      ,[Model]
      ,[Version]
      ,[Holes]
      ,[Color]
      ,[ProductTypeId]
      ,[ar_gruppo]
      ,[ar_sotgru]
      ,[ar_famprod]
      ,[ar_cersotgrup]
      ,[WeightKg]
      ,[ManufCode]
      from [77.81.228.147].dbmax.dbo.Wheels where Id='<ID_PRODOTTO_TEST>'
     union ALL
*/
     select
        distinct -- safe
       pr.[Id]
      ,[SmallImgUrl]='https://photo.topruote.com/small/'+pr.ImgName
      ,[MediumImgUrl]='https://photo.topruote.com/medium/'+pr.ImgName
      ,[LargeImgUrl]='https://photo.topruote.com/large/'+pr.ImgName
      ,pr.[Descr]
      ,[LastPurchPrice]=cast(wp.TopBuyingPriceNts as decimal(18,2))
      ,pr.[EanCod]
      ,pr.[VehicleTypes]
      ,pr.[WhWidth]
      ,pr.[Diameter]
      ,pr.[WhOffset]
      ,pr.[WhPcd1]
      ,pr.[WhPcd2]
      ,pr.[WhPcd3]
      ,pr.[WhMinBoreDiam]
      ,pr.[WhMaxBoreDiam]
      ,pr.[WhIntHeft]
      ,pr.[WhExtHeft]
      ,[Brand]=br.Descr
      ,[Model]=pm.Descr
      ,[Version]=wv.Descr
      ,[Holes]=wv.Holes
      ,[Color]=wc.Descr
      ,pr.[ProductTypeId]
      ,[ar_gruppo]=cast(format(power(2, ISNULL(pr.ProductTypeId, 0)), '00') as nvarchar(2))
      ,[ar_sotgru]=cast(format(power(2, ISNULL(pr.ProductTypeId, 0)), '00') + format(1, '00') as nvarchar(4))
      ,[ar_famprod]=br.NtsCodCfam
      ,[ar_cersotgrup]=cast(null as nvarchar(100)) -- TODO: verificare formula corretta lato DbMax
      ,pr.WeightKg
      ,[ManufCode]=pr.ManufacturerCod
  FROM [192.168.100.52].[WheelSystems].[dbo].[Products] pr
  left join [192.168.100.52].[WheelsNet].[dbo].[WheelPrices] wp on wp.ProductId=pr.Id
  left join [192.168.100.52].[WheelSystems].[dbo].[Brands] br on br.Id=pr.BrandId
  left join [192.168.100.52].[WheelSystems].[dbo].[ProductModels] pm ON pm.Id=pr.ProductModelId
  left join [192.168.100.52].[WheelSystems].[dbo].[WhVersions] wv ON wv.Id=pr.WhVersionId
  left join [192.168.100.52].[WheelSystems].[dbo].[WhColors] wc ON wc.Id=wv.WhColorId
WHERE
    pr.ProductTypeId IN (2, 3)
    --and pr.Id = '<ID_PRODOTTO_TEST>'
GO
