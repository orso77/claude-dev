USE [WheelsNet]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
exec WheelsNetSpFillFitmentSpares;
*/
ALTER procedure [dbo].[SpFillFitmentSpares]
as
begin

	drop table if exists #FitmentSpares;

	SELECT
		   [VehicleBrandId]=ve.BrandId
		  ,[VehicleBrand]=WheelsNet.dbo.FnNormalizeString(ve.Brand)
		  ,[VehicleModelId]=ho.VehicleModelId
		  ,[VehicleModelIdEncr]=dbo.FnEncryptVehicleModelId(ho.VehicleModelId)
		  ,[VehicleModel]=WheelsNet.dbo.FnNormalizeString(ve.Model)
		  ,[VehicleChassis]=WheelsNet.dbo.FnNormalizeString(ve.Chassis)
		  ,[VehicleModelType]=WheelsNet.dbo.FnNormalizeString(ve.ModelType)
		  ,[VehicleModelFromYear]=ve.ModelFromYear
		  ,[VehicleModelToYear]=ve.ModelToYear
		  ,[VehicleHoles]=ve.ChassisHoles
		  ,[VehiclePcd]=WheelsNet.dbo.FnNormalizeString(ve.ChassisPcd)
		  ,[VehicleCentreBore]=WheelsNet.dbo.FnNormalizeString(ve.ChassisCentreBore)
		  ,[VehicleMaxWheelLoad]=ve.ChassisMaxWheelLoad
		  ,[VehicleKwFrom]=ve.ModelKwFrom
		  ,[VehicleKwTo]=ve.ModelKwTo
		  ,[VehicleHasTpms]=ve.HasTpms
		  ,[VehicleKtypes]=ve.Ktypes
		  ,[VehicleAbeCodes]=ve.AbeCodes
		  ,[VehicleTyres]=isnull(ty.Tyres,'')
		  ,[WheelTypeId]=4
		  ,[WheelType]=WheelsNet.dbo.FnNormalizeString(wh.ProductType)
		  ,[WheelTypeEn]=WheelsNet.dbo.FnNormalizeString(wh.ProductTypeEn)
		  ,[WheelBrandId]=wh.BrandId
		  ,[WheelBrand]=WheelsNet.dbo.FnNormalizeString(br.Descr)
		  ,[WheelBrandImgName]=WheelsNet.dbo.FnNormalizeString(br.Img)
		  ,[WheelId]=wh.Id
		  ,[WheelEan]=WheelsNet.dbo.FnNormalizeString(wh.Ean)
		  ,[WheelManufacturerCode]=WheelsNet.dbo.FnNormalizeString(wh.ManufacturerCode)
		  ,[WheelDescr]=WheelsNet.dbo.FnNormalizeString(wh.Descr)
          ,[WheelDescrEn]=WheelsNet.dbo.FnNormalizeString(wh.DescrEn)
		  ,[WheelImgName1]=WheelsNet.dbo.FnNormalizeString(wh.Img1)
		  ,[WheelImgName2]=WheelsNet.dbo.FnNormalizeString(wh.Img2)
		  ,[WheelImgName3]=WheelsNet.dbo.FnNormalizeString(wh.Img3)
		  ,[WheelImgName4]=WheelsNet.dbo.FnNormalizeString(wh.Img4)
		  ,[WheelImgName5]=WheelsNet.dbo.FnNormalizeString(wh.Img5)
		  ,[WheelWidth]=wh.Width
		  ,[WheelDiameter]=wh.Diameter
		  ,[WheelHoles]=wh.Holes
		  ,[WheelPcd1]=wh.Pcd1
		  ,[WheelMaxLoad]=wh.MaxLoad
		  ,[WheelMadeIn]=WheelsNet.dbo.FnNormalizeString(wh.MadeIn)
		  ,[HomologationNotes]=WheelsNet.dbo.FnNormalizeString(ho.Notes)
		  ,[Timestamp]=ho.Timestamp
	  into #FitmentSpares
	  FROM [WheelsNet].[dbo].[HomologationSpares] ho
	  inner join WheelsNet.dbo.Vehicles ve on ve.ModelId=ho.VehicleModelId
	  inner join WheelsNet.dbo.Spares wh on
			ho.SpareBrandId=wh.BrandId and ho.SpareManufacturerCode = wh.ManufacturerCode
	  left join WheelsNet.dbo.ViewModelTyres ty on ty.ModelId=ho.VehicleModelId and ty.Diameter=wh.Diameter
	  inner join WheelsNet.dbo.Brands br on br.Id=ho.SpareBrandId
	  where
		wh.PubblicationTypes > 0
		and ve.Enabled = 1

	truncate table WheelsNet.dbo.FitmentSpares;

	INSERT INTO WheelsNet.[dbo].[FitmentSpares]
	(
       [VehicleBrandId]
      ,[VehicleBrand]
      ,[VehicleModelId]
	  ,[VehicleModelIdEncr]
      ,[VehicleModel]
      ,[VehicleChassis]
      ,[VehicleModelType]
      ,[VehicleModelFromYear]
      ,[VehicleModelToYear]
      ,[VehicleHoles]
      ,[VehiclePcd]
      ,[VehicleCentreBore]
      ,[VehicleMaxWheelLoad]
      ,[VehicleKwFrom]
      ,[VehicleKwTo]
      ,[VehicleHasTpms]
      ,[VehicleKtypes]
      ,[VehicleAbeCodes]
      ,[VehicleTyres]
      ,[WheelTypeId]
      ,[WheelType]
      ,[WheelTypeEn]
      ,[WheelBrandId]
      ,[WheelBrand]
      ,[WheelBrandImgName]
      ,[WheelId]
      ,[WheelEan]
      ,[WheelCode]
      ,[WheelManufacturerCode]
      ,[WheelDescr]
      ,[WheelDescrEn]
      ,[WheelModel]
      ,[WheelVersionCode]
      ,[WheelVersion]
      ,[WheelImgName1]
      ,[WheelImgName2]
      ,[WheelImgName3]
      ,[WheelImgName4]
      ,[WheelImgName5]
      ,[WheelWidth]
      ,[WheelDiameter]
      ,[WheelHoles]
      ,[WheelPcd1]
      ,[WheelPcd2]
      ,[WheelPcd3]
      ,[WheelOffset]
      ,[WheelMaxBoreDiam]
      ,[WheelMaxLoad]
      ,[WheelColorCode]
      ,[WheelColor]
      ,[WheelMadeIn]
      ,[Homologation]
      ,[HomologationCode]
      ,[HomologationAxles]
      ,[HomologationNotes]
      ,[HomologationFiles]
      ,[HomologationTyres]
      ,[HomologationIsExternalSource]
      ,[HomologationIsTemporaryFitment]
      ,[HomologationHasInterchangeableOeCup]
      ,[HomologationUseOeFasteners]
      ,[HasWrongPattern]
      ,[KitsetId]
      ,[KitsetCode]
      ,[KitsetDescr]
      ,[KitsetDescrEn]
      ,[Timestamp]
	)
	select
       [VehicleBrandId]
      ,[VehicleBrand]
      ,[VehicleModelId]
	  ,[VehicleModelIdEncr]
      ,[VehicleModel]
      ,[VehicleChassis]
      ,[VehicleModelType]
      ,[VehicleModelFromYear]
      ,[VehicleModelToYear]
      ,[VehicleHoles]
      ,[VehiclePcd]
      ,[VehicleCentreBore]
      ,[VehicleMaxWheelLoad]
      ,[VehicleKwFrom]
      ,[VehicleKwTo]
      ,[VehicleHasTpms]
      ,[VehicleKtypes]
      ,[VehicleAbeCodes]
      ,[VehicleTyres]
      ,[WheelTypeId]
      ,[WheelType]
      ,[WheelTypeEn]
      ,[WheelBrandId]
      ,[WheelBrand]
      ,[WheelBrandImgName]
      ,[WheelId]
      ,[WheelEan]
      ,[WheelCode]=''
      ,[WheelManufacturerCode]
      ,[WheelDescr]
      ,[WheelDescrEn]
      ,[WheelModel]=''
      ,[WheelVersionCode]=''
      ,[WheelVersion]=''
      ,[WheelImgName1]
      ,[WheelImgName2]
      ,[WheelImgName3]
      ,[WheelImgName4]
      ,[WheelImgName5]
      ,[WheelWidth]
      ,[WheelDiameter]
      ,[WheelHoles]
      ,[WheelPcd1]
      ,[WheelPcd2]=0.00
      ,[WheelPcd3]=0.00
      ,[WheelOffset]=0.00
      ,[WheelMaxBoreDiam]=0.00
      ,[WheelMaxLoad]
      ,[WheelColorCode]=''
      ,[WheelColor]=''
      ,[WheelMadeIn]
      ,[Homologation]=''
      ,[HomologationCode]=''
      ,[HomologationAxles]=''
      ,[HomologationNotes]
      ,[HomologationFiles]=''
      ,[HomologationTyres]=''
      ,[HomologationIsExternalSource]=0
      ,[HomologationIsTemporaryFitment]=0
      ,[HomologationHasInterchangeableOeCup]=0
      ,[HomologationUseOeFasteners]=0
      ,[HasWrongPattern]=0
      ,[KitsetId]=''
      ,[KitsetCode]=''
      ,[KitsetDescr]=''
      ,[KitsetDescrEn]=''
      ,[Timestamp]

	from  #FitmentSpares

	drop table if exists #FitmentSpares

end
