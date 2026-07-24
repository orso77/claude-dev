USE [replicaTopRuote]
GO
/*
select count(*) from WwKtypeChassisModels
select count(*) from WwKtypeChassisModels_Src
*/
create or alter view dbo.WwKtypeChassisModels_Src
as
/*
SELECT [Ktype]
      ,[ChassisId]
      ,[ModelId]
      ,[Notes]
      from [77.81.228.147].dbmax.dbo.WwKtypeChassisModels where Ktype = <KTYPE_TEST>
     union ALL
*/
     select
        distinct -- safe
        w.[Ktype]
      ,w.[ChassisId]
      ,w.[ModelId]
      ,[Notes]=cast(null as nvarchar(max))  -- la tabella sorgente non ha la colonna Notes
  FROM [192.168.100.52].[WheelSystems].[dbo].[WwKtypeChassisModels] w
GO
