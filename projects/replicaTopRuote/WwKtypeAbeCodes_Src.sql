USE [replicaTopRuote]
GO
/*
select count(*) from WwKtypeAbeCodes
select count(*) from WwKtypeAbeCodes_Src
*/
create or alter view dbo.WwKtypeAbeCodes_Src
as
/*
SELECT [Ktype]
      ,[AbeNr]
      from [77.81.228.147].dbmax.dbo.WwKtypeAbeCodes where Ktype = <KTYPE_TEST>
     union ALL
*/
     select
        distinct -- safe
        w.[Ktype]
      ,w.[AbeNr]
  FROM [192.168.100.52].[WheelSystems].[dbo].[WwKtypeAbeCodes] w
GO
