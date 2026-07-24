USE [replicaTopRuote]
GO
/*
select count(*) from WwTecDocManufacturers
select count(*) from WwTecDocManufacturers_Src
*/
create or alter view dbo.WwTecDocManufacturers_Src
as
/*
SELECT [ManufacturerId]
      ,[ManufacturerName]
      ,[LanguageId]
      ,[CountryId]
      ,[ExtManufacturerName]
      ,[ExtEnabled]
      from [77.81.228.147].dbmax.dbo.WwTecDocManufacturers where ManufacturerId = <MANUFACTURER_TEST>
     union ALL
*/
     select
        distinct -- safe
        w.[ManufacturerId]
      ,w.[ManufacturerName]
      ,w.[LanguageId]
      ,w.[CountryId]
      ,w.[ExtManufacturerName]
      ,w.[ExtEnabled]
  FROM [192.168.100.52].[WheelSystems].[dbo].[WwTecDocManufacturers] w
GO
