USE [replicaTopRuote]
GO
--select count(*) from Accessories_Src
create or alter view dbo.Accessories_Src
as
--SELECT [Id]
--      ,[SmallImgUrl]
--      ,[MediumImgUrl]
--      ,[LargeImgUrl]
--      ,[Descr]
--      ,[LastPurchPrice]
--      ,[Brand]
--      ,[Type1]
--      ,[Type2]
--      ,[EanCod]
--      ,[ar_gruppo]
--      ,[ar_sotgru]
--      ,[ar_famprod]
--      ,[WeightKg]
--      from [77.81.228.147].dbmax.dbo.Accessories where Id='<ID_PRODOTTO_TEST>'
--     union ALL
     select
        distinct -- safe
       pr.[Id]
      ,[SmallImgUrl]='https://photo.topruote.com/small/'+pr.ImgName
      ,[MediumImgUrl]='https://photo.topruote.com/medium/'+pr.ImgName
      ,[LargeImgUrl]='https://photo.topruote.com/large/'+pr.ImgName
      ,pr.[Descr]
      ,[LastPurchPrice]=cast(ap.TopBuyingPriceNts as decimal(18,2))
      ,[Brand]=br.Descr
      ,[Type1]=aa.Descr
      ,[Type2]=ab.Descr
      ,pr.[EanCod]
      ,[ar_gruppo]=cast(format(power(2, ISNULL(pr.ProductTypeId, 0)), '00') as nvarchar(2))
      ,[ar_sotgru]=cast(format(power(2, ISNULL(pr.ProductTypeId, 0)), '00') + format(1, '00') as nvarchar(4))
      ,[ar_famprod]=br.NtsCodCfam
      ,pr.WeightKg
      --select *
  FROM [192.168.100.52].[WheelSystems].[dbo].[Products] pr
  left join [192.168.100.52].[WheelsNet].[dbo].[AccessoryPrices] ap on ap.ProductId=pr.Id
  left join [192.168.100.52].[WheelSystems].[dbo].[Brands] br on br.Id=pr.BrandId
  left join [192.168.100.52].[WheelSystems].[dbo].[AcATypes] aa on aa.Id=pr.AcATypeId
  left join [192.168.100.52].[WheelSystems].[dbo].[AcBTypes] ab on ab.Id=pr.AcBTypeId
WHERE
    pr.ProductTypeId = 4
    --and pr.Id = '<ID_PRODOTTO_TEST>'
GO
