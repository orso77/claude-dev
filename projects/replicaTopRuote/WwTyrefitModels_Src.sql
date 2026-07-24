USE [replicaTopRuote]
GO
/*
select count(*) from WwTyrefitModels
select count(*) from WwTyrefitModels_Src
*/
create or alter view dbo.WwTyrefitModels_Src
as
/*
SELECT [ModelId]
      ,[ChassisId]
      ,[ModelName]
      ,[TyreSize]
      ,[LoadIndex]
      ,[SpeedIndex]
      ,[TyrePressure]
      ,[RimSize]
      ,[RimOffset]
      ,[TyreSizeR]
      ,[LoadIndexR]
      ,[SpeedIndexR]
      ,[TyrePressureR]
      ,[RimSizeR]
      ,[OffsetR]
      ,[ModelLadenTpF]
      ,[ModelLadenTpR]
      ,[Runflatf]
      ,[Runflatr]
      ,[ExtraloadF]
      ,[ExtraloadR]
      ,[OeDescription]
      from [77.81.228.147].dbmax.dbo.WwTyrefitModels where ModelId = <MODEL_TEST>
     union ALL
*/
     select
        distinct -- safe
        w.[ModelId]
      ,w.[ChassisId]
      ,w.[ModelName]
      ,w.[TyreSize]
      ,w.[LoadIndex]
      ,w.[SpeedIndex]
      ,w.[TyrePressure]
      ,w.[RimSize]
      ,w.[RimOffset]
      ,w.[TyreSizeR]
      ,w.[LoadIndexR]
      ,w.[SpeedIndexR]
      ,w.[TyrePressureR]
      ,w.[RimSizeR]
      ,w.[OffsetR]
      ,w.[ModelLadenTpF]
      ,w.[ModelLadenTpR]
      ,w.[Runflatf]
      ,w.[Runflatr]
      ,w.[ExtraloadF]
      ,w.[ExtraloadR]
      ,w.[OeDescription]
  FROM [192.168.100.52].[WheelSystems].[dbo].[WwTyrefitModels] w
GO
