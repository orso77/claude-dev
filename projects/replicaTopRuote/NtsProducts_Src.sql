USE [replicaTopRuote]
GO
/*
select count(*) from NtsProducts
select count(*) from NtsProducts_Src
*/
create or alter view dbo.NtsProducts_Src
as
/*
SELECT [Id]
      ,[ProductTypeId]
      ,[Descr]
      ,[NetPrice]
      ,[VatId]
      from [77.81.228.147].[WheelSystems].[dbo].[NtsProducts] where Id = '<ID_TEST>'
     union ALL
*/
     select
        distinct -- safe
        n.[Id]
      ,n.[ProductTypeId]
      ,n.[Descr]
      ,n.[NetPrice]
      ,n.[VatId]
  FROM [192.168.100.52].[WheelSystemsTopruote].[dbo].[NtsProducts] n
GO
