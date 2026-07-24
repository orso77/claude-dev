USE [replicaTopRuote]
GO
--select count(*) from KtypeSpareWheels_Src
create or alter view dbo.KtypeSpareWheels_Src
as
--SELECT [Ktype]
--      ,[ProductId]
--      ,[Notes]
--      from [77.81.228.147].dbmax.dbo.KtypeSpareWheels where Ktype = <KTYPE_TEST>
--     union ALL
     select
        k.[Ktype]
      ,k.[ProductId]
      ,k.[Notes]
  FROM [192.168.100.52].[WheelsNet].[dbo].[KtypeSpareWheels] k
GO
