
	drop table if exists #HomologationWheels;

	with Base as (
		select
			 ho.ModelId
			,SupplierProdCode = ISNULL(WheelsNet.dbo.FnNormalizeString(ho.SupplierProdCode), '')
			,ApprovalTypeDescr = ISNULL(WheelsNet.dbo.FnNormalizeString(ho.ApprovalTypeDescr), '')
			,ApprCertCode = ISNULL(WheelsNet.dbo.FnNormalizeString(ho.ApprCertCode), '')
			----------------------------------------------------------------------------------------------------------
			,ho.AxlesId
			,ho.InterchangeableOeCup
			,ho.UseOeFasteners
			,KitsetBrandId = ISNULL(WheelsNet.dbo.FnNormalizeString(br.NtsCodCFam), '')
			,PdfList = ISNULL(ho.PdfList, '')
			,Notes = ISNULL(WheelsNet.dbo.FnNormalizeString(ho.Notes), '')
			,KitsetCode = ISNULL(WheelsNet.dbo.FnNormalizeString(ho.KitsetCode), '')
			,TyreList = ISNULL(ho.TyreList, '')
			,Ktype = ISNULL(CAST(ve.Ktype AS VARCHAR(50)), '')
		FROM
			WheelSystems.[dbo].[SysHomologationModelIds_202511210400] ho
			left join WheelSystems.dbo.Brands br on br.Id = ho.KitsetBrandId
			inner join WheelsNet.dbo.TecDocVehicles ve on ve.ModelId = ho.ModelId
			inner join WheelsNet.dbo.TecDocModels mo on mo.ModelId=ve.ModelId
			inner join WheelsNet.dbo.Wheels wh on wh.Id = ho.ProductId
		where
			ho.ModelId=28 and ho.SupplierProdCode='F6560MIBM45FP3Y' and
			/*
			select * from WheelSystems.[dbo].[SysHomologationModelIds_202511210400] ho where ho.ModelId=11221 and ho.SupplierProdCode='TTY78SA35' 
			*/
			----------------------------------
			--wh.PubblicationTypes > 0
			mo.Enabled = 1
			and ho.IsExternalSource = 1
	)
	-- Tyres: pulizia (rimozione indice carico e codice velocita), distinct, ordinamento, string_agg
	,TyreClean as (
		select distinct
			 b.ModelId
			,b.SupplierProdCode
			,b.ApprovalTypeDescr
			,b.ApprCertCode
			,CleanTyre = CASE
				WHEN PATINDEX('%R[0-9][0-9]%', t.NormTyre) > 0
				THEN LEFT(t.NormTyre, PATINDEX('%R[0-9][0-9]%', t.NormTyre) + 2)
				ELSE t.NormTyre
			END
		FROM Base b
		CROSS APPLY STRING_SPLIT(b.TyreList, ',') s
		CROSS APPLY (SELECT NormTyre = REPLACE(REPLACE(LTRIM(RTRIM(s.value)), ' R', 'R'), 'ZR', 'R')) t
		where b.TyreList > ''
			and LTRIM(RTRIM(s.value)) > ''
	)
	,TyreAgg as (
		select
			 ModelId
			,SupplierProdCode
			,ApprovalTypeDescr
			,ApprCertCode
			,HomologationTyres = ISNULL(STRING_AGG(CleanTyre, ',') WITHIN GROUP (ORDER BY CleanTyre), '')
		FROM TyreClean
		group by
			 ModelId
			,SupplierProdCode
			,ApprovalTypeDescr
			,ApprCertCode
	)
	-- Notes: distinct, string_agg
	,NotesDistinct as (
		select distinct
			 ModelId
			,SupplierProdCode
			,ApprovalTypeDescr
			,ApprCertCode
			,Notes
		FROM Base
		where Notes > ''
	)
	,NotesAgg as (
		select
			 ModelId
			,SupplierProdCode
			,ApprovalTypeDescr
			,ApprCertCode
			,HomologationNotes = ISNULL(STRING_AGG(Notes, ','), '')
		FROM NotesDistinct
		group by
			 ModelId
			,SupplierProdCode
			,ApprovalTypeDescr
			,ApprCertCode
	)
	-- Ktypes (AbeCodeList): distinct, ordinamento, string_agg
	,KtypeDistinct as (
		select distinct
			 ModelId
			,SupplierProdCode
			,ApprovalTypeDescr
			,ApprCertCode
			,Ktype
		FROM Base
		where Ktype > ''
	)
	,KtypeAgg as (
		select
			 ModelId
			,SupplierProdCode
			,ApprovalTypeDescr
			,ApprCertCode
			,HomologationKtypes = ISNULL(STRING_AGG(Ktype, ',') WITHIN GROUP (ORDER BY Ktype), '')
		FROM KtypeDistinct
		group by
			 ModelId
			,SupplierProdCode
			,ApprovalTypeDescr
			,ApprCertCode
	)
	-- Files (PdfList): distinct, string_agg
	,FileDistinct as (
		select distinct
			 ModelId
			,SupplierProdCode
			,ApprovalTypeDescr
			,ApprCertCode
			,SingleFile = LTRIM(RTRIM(s.value))
		FROM Base
		CROSS APPLY STRING_SPLIT(PdfList, ',') s
		where PdfList > ''
			and LTRIM(RTRIM(s.value)) > ''
	)
	,FileAgg as (
		select
			 ModelId
			,SupplierProdCode
			,ApprovalTypeDescr
			,ApprCertCode
			,HomologationFiles = ISNULL(STRING_AGG(SingleFile, ','), '')
		FROM FileDistinct
		group by
			 ModelId
			,SupplierProdCode
			,ApprovalTypeDescr
			,ApprCertCode
	)
	-- Aggregazione MAX per i campi rimanenti
	,Agg as (
		select
			 ModelId
			,SupplierProdCode
			,ApprovalTypeDescr
			,ApprCertCode
			,MaxAxlesId = MAX(CAST(ISNULL(AxlesId, 0) AS INT))
			,HasInterchangeableOeCup = MAX(ISNULL(CAST(InterchangeableOeCup AS INT), 0))
			,UseOeFasteners = MAX(ISNULL(CAST(UseOeFasteners AS INT), 0))
			,KitsetBrandId = MAX(ISNULL(KitsetBrandId, ''))
			,KitsetCode = MAX(ISNULL(KitsetCode, ''))
		FROM Base
		group by
			 ModelId
			,SupplierProdCode
			,ApprovalTypeDescr
			,ApprCertCode
	)
	-- Lookup AxlesId -> AxlesDescr (es. 2=Ant., 4=Post., 6=Ant./Post.)
	,AxlesMap as (
		select AxlesId = MAX(AxlesId)
		FROM Base
		where AxlesId is not null
		group by AxlesId
	)
	SELECT
		 [VehicleModelId] = ag.ModelId
		,[WheelHomolCode] = ''
		,[WheelManufacturerCode] = ag.SupplierProdCode
		,[Homologation] = ISNULL(ag.ApprovalTypeDescr, '')
		,[HomologationCode] = ISNULL(ag.ApprCertCode, '')
		,[HomologationAxles] =case
								when ISNULL(ax.AxlesId,0)=2 then 'FRONT'
								when ISNULL(ax.AxlesId,0)=4 then 'REAR'
								when ISNULL(ax.AxlesId,0)=6 then 'FRONT-REAR'
								else ''
							end		
		,[HomologationKtypes] = ISNULL(kt.HomologationKtypes, '')
		,[HomologationNotes] = ISNULL(nt.HomologationNotes, '')
		,[HomologationFiles] = ISNULL(fl.HomologationFiles, '')
		,[HomologationTyres] = ISNULL(ty.HomologationTyres, '')
		,[HomologationTyreNotes] = ''
		,[HasInterchangeableOeCup] = ISNULL(ag.HasInterchangeableOeCup, 0)
		,[UseOeFasteners] = ISNULL(ag.UseOeFasteners, 0)
		,[OnlyForOeSteelWheels] = CAST(0 AS BIT)
		,[HasBrakeWarning] = CAST(0 AS BIT)
		,[KitsetBrandId] = ISNULL(ag.KitsetBrandId, '')
		,[KitsetManufacturerCode] = ISNULL(ag.KitsetCode, '')
		,[Timestamp] = GETDATE()
	into #HomologationWheels
	FROM Agg ag
	left join AxlesMap ax on ax.AxlesId = ag.MaxAxlesId
	left join TyreAgg ty
		on  ty.ModelId = ag.ModelId
		and ty.SupplierProdCode = ag.SupplierProdCode
		and ty.ApprovalTypeDescr = ag.ApprovalTypeDescr
		and ty.ApprCertCode = ag.ApprCertCode
	left join NotesAgg nt
		on  nt.ModelId = ag.ModelId
		and nt.SupplierProdCode = ag.SupplierProdCode
		and nt.ApprovalTypeDescr = ag.ApprovalTypeDescr
		and nt.ApprCertCode = ag.ApprCertCode
	left join KtypeAgg kt
		on  kt.ModelId = ag.ModelId
		and kt.SupplierProdCode = ag.SupplierProdCode
		and kt.ApprovalTypeDescr = ag.ApprovalTypeDescr
		and kt.ApprCertCode = ag.ApprCertCode
	left join FileAgg fl
		on  fl.ModelId = ag.ModelId
		and fl.SupplierProdCode = ag.SupplierProdCode
		and fl.ApprovalTypeDescr = ag.ApprovalTypeDescr
		and fl.ApprCertCode = ag.ApprCertCode
	;
/*
--debug
	select * from #HomologationWheels
	return
*/
	 delete from WheelsNet.dbo.HomologationWheels_restored;
	 INSERT INTO WheelsNet.[dbo].[HomologationWheels_restored]
	        ([VehicleModelId]
	        ,[WheelHomolCode]
	        ,[WheelManufacturerCode]
	        ,[Homologation]
	        ,[HomologationCode]
	        ,[HomologationAxles]
	        ,[HomologationKtypes]
	        ,[HomologationNotes]
	        ,[HomologationFiles]
	        ,[HomologationTyres]
	        ,[HomologationTyreNotes]
	        ,[HasInterchangeableOeCup]
	        ,[UseOeFasteners]
	        ,[OnlyForOeSteelWheels]
	        ,[HasBrakeWarning]
	        ,[KitsetBrandId]
	        ,[KitsetManufacturerCode]
	        ,[Timestamp])
	select
		 [VehicleModelId]
		,[WheelHomolCode]
		,[WheelManufacturerCode]
		,[Homologation]
		,[HomologationCode]
		,[HomologationAxles]
		,[HomologationKtypes]
		,[HomologationNotes]
		,[HomologationFiles]
		,[HomologationTyres]
		,[HomologationTyreNotes]
		,[HasInterchangeableOeCup]
		,[UseOeFasteners]
		,[OnlyForOeSteelWheels]
		,[HasBrakeWarning]
		,[KitsetBrandId]
		,[KitsetManufacturerCode]
		,[Timestamp]
	from
		#HomologationWheels

	drop table if exists #HomologationWheels
