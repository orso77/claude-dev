USE [replicaTopRuote]
GO
/*
select count(*) from Brands
select count(*) from Brands_Src
*/
create or alter view dbo.Brands_Src
as
/*
SELECT [Id]
      ,[Descr]
      ,[ImgUrl]
      ,[NtsCodCfam]
      from [77.81.228.147].dbmax.dbo.Brands where Id = 1
     union ALL
*/
     select
        distinct -- safe
        br.[Id]
      ,br.[Descr]
      ,[ImgUrl]=isnull(br.ImgPath, '')
      ,br.[NtsCodCfam]
  FROM [192.168.100.52].[WheelSystems].[dbo].[Brands] br
--  where Id= 1
GO
