USE [WheelsNet]
GO
/****** Object:  StoredProcedure [dbo].[SpFillFitmentWheels]    Script Date: 3/31/2026 7:18:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
select [HomologationIsExternalSource],count(*) from WheelsNet.dbo.FitmentWheels group by [HomologationIsExternalSource]
truncate table WheelsNet.dbo.FitmentWheels;
exec SpFillFitmentWheels 0, 0;
exec SpFillFitmentWheels 1, 0;
*/
ALTER procedure [dbo].[SpFillFitmentWheels]
	@homologationIsExternalSource bit,
	@onlyRecents bit = 0,
	@debug bit = 0
as
begin

	drop table if exists #FitmentWheels;
	
	SELECT 
		--distinct
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
		  ,[WheelTypeId]=wh.ProductTypeId
		  ,[WheelType]=WheelsNet.dbo.FnNormalizeString(wh.ProductType)
		  ,[WheelTypeEn]=WheelsNet.dbo.FnNormalizeString(wh.ProductTypeEn)
		  ,[WheelBrandId]=wh.BrandId
		  ,[WheelBrand]=WheelsNet.dbo.FnNormalizeString(br.Descr)
		  ,[WheelBrandImgName]=WheelsNet.dbo.FnNormalizeString(br.Img)
		  ,[WheelId]=wh.Id
		  ,[WheelEan]=WheelsNet.dbo.FnNormalizeString(wh.Ean)
		  ,[WheelCode]=WheelsNet.dbo.FnNormalizeString(case when @homologationIsExternalSource=1 then '' else isnull(wh.HomolCode1,'') end)
		  ,[WheelManufacturerCode]=WheelsNet.dbo.FnNormalizeString(wh.ManufacturerCode)
		  ,[WheelDescr]=WheelsNet.dbo.FnNormalizeString(wh.Descr)
		  ,[WheelDescrEn]=WheelsNet.dbo.FnNormalizeString(wh.DescrEn)
		  ,[WheelModel]=WheelsNet.dbo.FnNormalizeString(wh.Model)
		  ,[WheelVersionCode]=WheelsNet.dbo.FnNormalizeString(wh.VersionCode)
		  ,[WheelVersion]=WheelsNet.dbo.FnNormalizeString(wh.Version)
		  ,[WheelImgName1]=WheelsNet.dbo.FnNormalizeString(wh.Img1)
		  ,[WheelImgName2]=WheelsNet.dbo.FnNormalizeString(wh.Img2)
		  ,[WheelImgName3]=WheelsNet.dbo.FnNormalizeString(wh.Img3)
		  ,[WheelImgName4]=WheelsNet.dbo.FnNormalizeString(wh.Img4)
		  ,[WheelImgName5]=WheelsNet.dbo.FnNormalizeString(wh.Img5)
		  ,[WheelWidth]=wh.Width
		  ,[WheelDiameter]=wh.Diameter
		  ,[WheelHoles]=wh.Holes
		  ,[WheelPcd1]=wh.Pcd1
		  ,[WheelPcd2]=wh.Pcd2
		  ,[WheelPcd3]=wh.Pcd3
		  ,[WheelOffset]=wh.Offset
		  ,[WheelMaxBoreDiam]=wh.MaxBoreDiam
		  ,[WheelMaxLoad]=wh.MaxLoad
		  ,[WheelColorCode]=WheelsNet.dbo.FnNormalizeString(wh.ColorCode)
		  ,[WheelColor]=WheelsNet.dbo.FnNormalizeString(wh.Color)
		  ,[WheelMadein]=WheelsNet.dbo.FnNormalizeString(wh.MadeIn)
		  ,[Homologation]=WheelsNet.dbo.FnNormalizeString(case when @homologationIsExternalSource=0 and wh.HomolCode2 = ho.WheelHomolCode then '' else ho.Homologation end)
		  ,[HomologationCode]=WheelsNet.dbo.FnNormalizeString(case when @homologationIsExternalSource=0 and wh.HomolCode2 = ho.WheelHomolCode then '' else ho.HomologationCode end)
		  ,[HomologationAxles]=WheelsNet.dbo.FnNormalizeString(ho.HomologationAxles)
		  ,[HomologationNotes]=WheelsNet.dbo.FnNormalizeString(ho.HomologationNotes)
		  ,[HomologationFiles]=WheelsNet.dbo.FnNormalizeString(case when @homologationIsExternalSource=1 or wh.HomolCode2 = ho.WheelHomolCode then '' else ho.HomologationFiles end)
		  ,[HomologationTyres]=ho.HomologationTyres
		  ,[HomologationTyreNotes]=WheelsNet.dbo.FnNormalizeString(ho.HomologationTyreNotes)
		  ,[HomologationIsExternalSource]=@homologationIsExternalSource
		  ,[HomologationIsTemporaryFitment]=case when @homologationIsExternalSource=1 then 0 else cast(Case when wh.HomolCode2=ho.WheelHomolCode then 1 else 0 end as bit) end
		  ,[HomologationHasInterchangeableOeCup]=ho.HasInterchangeableOeCup
		  ,[HomologationUseOeFasteners]=ho.UseOeFasteners
		  ,[HomologationOnlyForOeSteelWheels]=ho.OnlyForOeSteelWheels
		  ,[HomologationHasBrakeWarning]=ho.HasBrakeWarning
		  ,[HasWrongPattern]=cast(Case when wh.Holes<>ve.ChassisHoles then 1 else 0 end as bit)
		  ,[KitsetId]=WheelsNet.dbo.FnNormalizeString(kit.Id)
		  ,[KitsetCode]=WheelsNet.dbo.FnNormalizeString(kit.ManufacturerCode)
		  ,[KitsetDescr]=WheelsNet.dbo.FnNormalizeString(kit.Descr)
		  ,[KitsetDescrEn]=WheelsNet.dbo.FnNormalizeString(kit.DescrEn)
		  ,[Timestamp]=ho.Timestamp
	  
	  into #FitmentWheels
	  FROM [WheelsNet].[dbo].[HomologationWheels] ho
	  inner join WheelsNet.dbo.Vehicles ve on ve.ModelId=ho.VehicleModelId
	  left join WheelsNet.dbo.Kitsets kit on kit.BrandId=ho.KitsetBrandId and kit.ManufacturerCode=ho.KitsetManufacturerCode
	  inner join WheelsNet.dbo.Wheels wh on 
			(ho.WheelHomolCode>'' and trim(isnull(nullif(wh.HomolCode1,''),wh.HomolCode2)) = ho.WheelHomolCode)
			or (ho.WheelHomolCode='' and  ho.WheelManufacturerCode>'' and wh.ManufacturerCode = ho.WheelManufacturerCode)
	  left join WheelsNet.dbo.ViewModelTyres ty on ty.ModelId=ho.VehicleModelId and ty.Diameter=wh.Diameter
	  inner join WheelsNet.dbo.Brands br on br.Id=wh.BrandId
	  where
		((@homologationIsExternalSource=1 and ho.WheelHomolCode='' and  ho.WheelManufacturerCode>'')
								or (@homologationIsExternalSource=0 and ho.WheelHomolCode>'')) 
		and (@onlyRecents=0 or ho.Timestamp >= cast(getdate() as date))
		and wh.PubblicationTypes > 0
		and ve.Enabled = 1
		and (
				@homologationIsExternalSource=0 or
				not exists 
				(
					select 1 from  [WheelsNet].[dbo].[FitmentWheels] b where HomologationIsExternalSource = 0 and b.VehicleModelId=ho.VehicleModelId and b.WheelId=wh.Id
				)	
		)
	
	if (@debug=1) begin
		if (@homologationIsExternalSource=1) begin
			drop table if exists FitmentWheels_Temp;
			select * into FitmentWheels_Temp from #FitmentWheels;
		end
		else begin
			drop table if exists FitmentWheelApprovals_Temp;
			select * into FitmentWheelApprovals_Temp from #FitmentWheels;
		end
	end

	if (@onlyRecents=0) begin
		delete from WheelsNet.dbo.FitmentWheels where isnull(HomologationIsExternalSource,0) = @homologationIsExternalSource;
	end
	else begin
		delete a
		FROM 
			[WheelsNet].[dbo].[FitmentWheels] a
		where
			isnull(a.HomologationIsExternalSource,0) = @homologationIsExternalSource
			and exists 
			(
				select 1 from #FitmentWheels b where b.VehicleModelId=a.VehicleModelId and b.WheelId=a.WheelId
			)
	end
		
	if (@homologationIsExternalSource=0) begin
		delete a
		FROM 
			[WheelsNet].[dbo].[FitmentWheels] a
		where
			HomologationIsExternalSource = 1
			and exists 
			(
				select 1 from #FitmentWheels b where b.HomologationIsExternalSource = 0 and b.VehicleModelId=a.VehicleModelId and b.WheelId=a.WheelId
			)
	end

	INSERT INTO WheelsNet.[dbo].[FitmentWheels]
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
      ,[HomologationTyreNotes]
      ,[HomologationIsExternalSource]
      ,[HomologationIsTemporaryFitment]
      ,[HomologationHasInterchangeableOeCup]
      ,[HomologationUseOeFasteners]
      ,[HomologationOnlyForOeSteelWheels]
      ,[HomologationHasBrakeWarning]
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
      ,[HomologationTyreNotes]
      ,[HomologationIsExternalSource]
      ,[HomologationIsTemporaryFitment]
      ,[HomologationHasInterchangeableOeCup]
      ,[HomologationUseOeFasteners]
	  ,[HomologationOnlyForOeSteelWheels]
      ,[HomologationHasBrakeWarning]
      ,[HasWrongPattern]
      ,[KitsetId]
      ,[KitsetCode]
      ,[KitsetDescr]
      ,[KitsetDescrEn]
      ,[Timestamp]
  
	from  #FitmentWheels

	drop table if exists #FitmentWheels

	truncate table WheelsNet.dbo.FitmentWheelKtypes
	insert into WheelsNet.dbo.FitmentWheelKtypes
	(
       [VehicleModelId]
      ,[VehicleKtype]
      ,[WheelId]
      ,[Timestamp]
	)
	select distinct
		 VehicleModelId
		,[VehicleKtype] = ltrim(rtrim(s.value))
		,t.WheelId,
		 timestamp=getdate()
	from WheelsNet.dbo.FitmentWheels t
	cross apply string_split(t.VehicleKtypes, ',') s
	where 
		isnull(HasWrongPattern,0)=0
		and ltrim(rtrim(s.value)) <> ''

	select 
		[HomologationIsExternalSource],
		[Rows]=count(*), 
		MinTimestamp=min(Timestamp),
		MaxTimestamp=max(Timestamp) 
	from 
		WheelsNet.dbo.FitmentWheels 
	group by 
		[HomologationIsExternalSource]
end
