USE [replicaTopRuote]
GO
/*
select count(*) from WwTecDocVehicles
select count(*) from WwTecDocVehicles_Src
*/
create or alter view dbo.WwTecDocVehicles_Src
as
/*
SELECT [Ktype]
      ,[LanguageId]
      ,[CountryId]
      ,[ModelId]
      ,[CarName]
      ,[ConstructionFrom]
      ,[ConstructionTo]
      ,[FirstCountry]
      ,[Cylinder]
      ,[CylinderCapacity]
      ,[CylinderCapacityCcm]
      ,[CylinderCapacityLiter]
      ,[Linked]
      ,[PowerHpFrom]
      ,[PowerHpTo]
      ,[PowerKwFrom]
      ,[PowerKwTo]
      ,[MotorCode]
      ,[ConstructionType]
      ,[ImpulsionType]
      ,[Valves]
      ,[ModelName]
      ,[TypeName]
      ,[TypeNumber]
      ,[FuelType]
      ,[FuelTypeProcess]
      ,[MotorType]
      ,[BrakeSystem]
      ,[CcmTech]
      ,[ExtAdded]
      from [77.81.228.147].dbmax.dbo.WwTecDocVehicles where Ktype = <KTYPE_TEST>
     union ALL
*/
     select
        distinct -- safe
        w.[Ktype]
      ,w.[LanguageId]
      ,w.[CountryId]
      ,w.[ModelId]
      ,w.[CarName]
      ,w.[ConstructionFrom]
      ,w.[ConstructionTo]
      ,w.[FirstCountry]
      ,w.[Cylinder]
      ,w.[CylinderCapacity]
      ,w.[CylinderCapacityCcm]
      ,w.[CylinderCapacityLiter]
      ,w.[Linked]
      ,w.[PowerHpFrom]
      ,w.[PowerHpTo]
      ,w.[PowerKwFrom]
      ,w.[PowerKwTo]
      ,w.[MotorCode]
      ,w.[ConstructionType]
      ,w.[ImpulsionType]
      ,w.[Valves]
      ,w.[ModelName]
      ,w.[TypeName]
      ,w.[TypeNumber]
      ,w.[FuelType]
      ,w.[FuelTypeProcess]
      ,w.[MotorType]
      ,w.[BrakeSystem]
      ,w.[CcmTech]
      ,w.[ExtAdded]
  FROM [192.168.100.52].[WheelSystems].[dbo].[WwTecDocVehicles] w
GO
