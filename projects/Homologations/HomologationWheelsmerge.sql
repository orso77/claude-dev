
MERGE [dbo].[HomologationWheels_merged] AS tgt
USING (SELECT * FROM [dbo].[HomologationWheels_restored] WHERE [WheelManufacturerCode] > '') AS src
ON  tgt.[VehicleModelId] = src.[VehicleModelId]
AND tgt.[WheelManufacturerCode] = src.[WheelManufacturerCode]
AND tgt.[Homologation] = src.[Homologation]
AND tgt.[HomologationCode] = src.[HomologationCode]
WHEN MATCHED THEN
	UPDATE SET
		 tgt.[WheelHomolCode] = src.[WheelHomolCode]
		,tgt.[HomologationAxles] = src.[HomologationAxles]
		,tgt.[HomologationKtypes] = src.[HomologationKtypes]
		,tgt.[HomologationNotes] = src.[HomologationNotes]
		,tgt.[HomologationFiles] = src.[HomologationFiles]
		,tgt.[HomologationTyres] = src.[HomologationTyres]
		,tgt.[HomologationTyreNotes] = src.[HomologationTyreNotes]
		,tgt.[HasInterchangeableOeCup] = src.[HasInterchangeableOeCup]
		,tgt.[UseOeFasteners] = src.[UseOeFasteners]
		,tgt.[OnlyForOeSteelWheels] = src.[OnlyForOeSteelWheels]
		,tgt.[HasBrakeWarning] = src.[HasBrakeWarning]
		,tgt.[KitsetBrandId] = src.[KitsetBrandId]
		,tgt.[KitsetManufacturerCode] = src.[KitsetManufacturerCode]
		--,tgt.[Timestamp] = src.[Timestamp]
WHEN NOT MATCHED BY TARGET THEN
	INSERT (
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
	)
	VALUES (
		 src.[VehicleModelId]
		,src.[WheelHomolCode]
		,src.[WheelManufacturerCode]
		,src.[Homologation]
		,src.[HomologationCode]
		,src.[HomologationAxles]
		,src.[HomologationKtypes]
		,src.[HomologationNotes]
		,src.[HomologationFiles]
		,src.[HomologationTyres]
		,src.[HomologationTyreNotes]
		,src.[HasInterchangeableOeCup]
		,src.[UseOeFasteners]
		,src.[OnlyForOeSteelWheels]
		,src.[HasBrakeWarning]
		,src.[KitsetBrandId]
		,src.[KitsetManufacturerCode]
		,'2025-12-31'
	)
WHEN NOT MATCHED BY SOURCE THEN
	DELETE
;
