USE [replicaTopRuote]
GO
/*
select count(*) from ProductSupplCodes
select count(*) from ProductSupplCodes_Src
*/
create or alter view dbo.ProductSupplCodes_Src
as
/*
SELECT [SupplierId]
      ,[SupplierDescr]
      ,[SupplierProdCod]
      ,[ProductId]
      ,[ManufacturerCod]
      from [77.81.228.147].dbmax.dbo.ProductSupplCodes where ProductId = '<ID_PRODOTTO_TEST>'
     union ALL
*/
     select
        distinct -- safe
        psc.[SupplierId]
      ,[SupplierDescr]=s.Descr
      ,psc.[SupplierProdCod]
      ,psc.[ProductId]
      ,[ManufacturerCod]=pr.ManufacturerCod  -- la tabella WheelSystems.ProductSupplCodes non ha ManufacturerCod, prendiamo da Products
  FROM [192.168.100.52].[WheelSystems].[dbo].[ProductSupplCodes] psc
  left join [192.168.100.52].[WheelSystemsTopruote].[dbo].[Suppliers] s on s.Id = psc.SupplierId
  left join [192.168.100.52].[WheelSystems].[dbo].[Products] pr on pr.Id = psc.ProductId
WHERE
    pr.ProductTypeId <> 1  -- coerente con tables-to-sync.txt che esclude ProductTypeId=1 (Tyres)
GO
