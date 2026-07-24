USE [replicaTopRuote]
GO
/*
select count(*) from WwTecDocModels
select count(*) from WwTecDocModels_Src
*/
create or alter view dbo.WwTecDocModels_Src
as
/*
SELECT [ModelId]
      ,[LanguageId]
      ,[CountryId]
      ,[ManufacturerId]
      ,[ModelName]
      ,[ConstructedFrom]
      ,[ConstructedTo]
      ,[ExtMainModelName]
      ,[ExtModelType]
      ,[ExtChassis]
      ,[ExtImgPath]
      ,[ExtApprovalRequired]
      ,[ExtEnabled]
      from [77.81.228.147].dbmax.dbo.WwTecDocModels where ModelId = <MODEL_TEST>
     union ALL
*/
     select
        distinct -- safe
        w.[ModelId]
      ,w.[LanguageId]
      ,w.[CountryId]
      ,w.[ManufacturerId]
      ,w.[ModelName]
      ,w.[ConstructedFrom]
      ,w.[ConstructedTo]
      ,w.[ExtMainModelName]
      ,w.[ExtModelType]
      ,w.[ExtChassis]
      ,w.[ExtImgPath]
      ,w.[ExtApprovalRequired]
      ,w.[ExtEnabled]
  FROM [192.168.100.52].[WheelSystems].[dbo].[WwTecDocModels] w
GO
