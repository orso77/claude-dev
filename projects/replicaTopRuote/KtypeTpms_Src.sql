USE [replicaTopRuote]
GO
--select count(*) from KtypeTpms_Src
create or alter view dbo.KtypeTpms_Src
as
--SELECT [Ktype]
--      ,[AccessoryId]
--      ,[ReLearn]
--      ,[OeNumber]
--      ,[Notes]
--      from [77.81.228.147].dbmax.dbo.KtypeTpms where Ktype = <KTYPE_TEST>
--     union ALL
     select
        k.[Ktype]
      ,k.[AccessoryId]
      ,k.[ReLearn]
      ,k.[OeNumber]
      ,k.[Notes]
  FROM [192.168.100.52].[WheelsNet].[dbo].[KtypeTpms] k
GO
