USE [replicaTopRuote]
GO
/*
select count(*) from WwTyrefitChassises
select count(*) from WwTyrefitChassises_Src
*/
create or alter view dbo.WwTyrefitChassises_Src
as
/*
SELECT [ChassisId]
      ,[ManufacturerId]
      ,[ChassisTitle]
      ,[Pcd]
      ,[CentreBore]
      ,[NutBoltThreadType]
      ,[NutBoltHex]
      ,[BoltLength]
      ,[NutBoltTorque]
      ,[MaxWheelLoad]
      from [77.81.228.147].dbmax.dbo.WwTyrefitChassises where ChassisId = <CHASSIS_TEST>
     union ALL
*/
     select
        distinct -- safe
        w.[ChassisId]
      ,w.[ManufacturerId]
      ,w.[ChassisTitle]
      ,w.[Pcd]
      ,w.[CentreBore]
      ,w.[NutBoltThreadType]
      ,w.[NutBoltHex]
      ,w.[BoltLength]
      ,w.[NutBoltTorque]
      ,w.[MaxWheelLoad]
  FROM [192.168.100.52].[WheelSystems].[dbo].[WwTyrefitChassises] w
GO
