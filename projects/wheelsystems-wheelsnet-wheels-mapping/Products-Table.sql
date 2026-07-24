USE [WheelSystems]
GO

/****** Object:  Table [dbo].[Products]    Script Date: 09/04/2026 17:55:04 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Products](
	[Id] [nchar](25) NOT NULL,
	[RowState] [int] NOT NULL,
	[InsDate] [datetime] NOT NULL,
	[InsUserId] [int] NOT NULL,
	[UpdDate] [datetime] NOT NULL,
	[UpdUserId] [int] NOT NULL,
	[PubblicationTypes] [bigint] NULL,
	[ProductTypeId] [int] NOT NULL,
	[Descr] [nvarchar](max) NOT NULL,
	[ExtDescr] [nvarchar](max) NULL,
	[VatId] [int] NOT NULL,
	[LastPurchPrice] [decimal](9, 2) NULL,
	[AvgPurchPrice] [decimal](9, 2) NULL,
	[ListPrice] [decimal](9, 2) NOT NULL,
	[BasePriceInStock] [decimal](9, 2) NOT NULL,
	[BasePriceOutStock] [decimal](9, 2) NOT NULL,
	[InStockDiscountProductPriceId] [int] NULL,
	[InStockMarkUpProductPriceId] [int] NULL,
	[OutStockDiscountProductPriceId] [int] NULL,
	[OutStockMarkUpProductPriceId] [int] NULL,
	[SpecialOffer] [int] NOT NULL,
	[BrandId] [int] NULL,
	[ProductModelId] [int] NULL,
	[EanCod] [nchar](25) NULL,
	[ManufacturerCod] [nchar](50) NULL,
	[StartRating] [decimal](9, 2) NULL,
	[VehicleTypes] [bigint] NULL,
	[ImgName] [nvarchar](max) NULL,
	[Diameter] [decimal](9, 2) NULL,
	[TyWidth] [decimal](9, 2) NULL,
	[TyAspRatio] [decimal](9, 2) NULL,
	[TyLoadIdx1] [decimal](9, 2) NULL,
	[TyLoadIdx2] [decimal](9, 2) NULL,
	[TySpeedId] [nchar](2) NULL,
	[TyEcoRollResist] [nvarchar](max) NULL,
	[TyEcoWetGrip] [nvarchar](max) NULL,
	[TyEcoNoiseLev] [int] NULL,
	[TyEcoNoiseDb] [int] NULL,
	[TyMs] [int] NULL,
	[TyRunFlat] [int] NULL,
	[TyReinf] [int] NULL,
	[TyCargo] [int] NULL,
	[TyZr] [int] NULL,
	[TyFr] [int] NULL,
	[TyXl] [int] NULL,
	[TyApplicationId] [nchar](25) NULL,
	[TyMeasureFormatId] [int] NULL,
	[TyCanvas] [int] NULL,
	[TyDot] [int] NULL,
	[TyDemo] [int] NULL,
	[WhVersionId] [int] NULL,
	[WhWidth] [decimal](9, 2) NULL,
	[WhOffset] [decimal](9, 2) NULL,
	[WhPcd1] [decimal](9, 2) NULL,
	[WhPcd2] [decimal](9, 2) NULL,
	[WhPcd3] [decimal](9, 2) NULL,
	[WhVarPcd] [int] NULL,
	[WhBoltHolesWidth] [decimal](9, 2) NULL,
	[WhBoltHolesHeight] [decimal](9, 2) NULL,
	[WhFastenerTypeId] [int] NULL,
	[WhSeatTypeId] [int] NULL,
	[WhMinBoreDiam] [decimal](9, 2) NULL,
	[WhMaxBoreDiam] [decimal](9, 2) NULL,
	[WhIntHeft] [decimal](9, 2) NULL,
	[WhExtHeft] [decimal](9, 2) NULL,
	[WhOmologCod] [nvarchar](max) NULL,
	[WhMaxLoad] [decimal](9, 2) NULL,
	[WhBrakesPassLimit] [int] NULL,
	[WhCupLimit] [int] NULL,
	[WhCupCod1] [nvarchar](max) NULL,
	[WhCupCod2] [nvarchar](max) NULL,
	[WhCupCod3] [nvarchar](max) NULL,
	[WhCupCod4] [nvarchar](max) NULL,
	[WhCupCod5] [nvarchar](max) NULL,
	[WhMeasureCod] [nvarchar](max) NULL,
	[WhKfzCode] [nchar](50) NULL,
	[WhWheelCod] [nchar](50) NULL,
	[AcATypeId] [int] NULL,
	[AcBTypeId] [int] NULL,
	[AcCTypeId] [int] NULL,
	[ChTypeId] [int] NULL,
	[BlTypeId] [int] NULL,
	[BlDimensionId] [int] NULL,
	[SpWidth] [decimal](9, 2) NULL,
	[SpAspRatio] [decimal](9, 2) NULL,
	[PackWidth] [decimal](9, 2) NULL,
	[PackLength] [decimal](9, 2) NULL,
	[PackHeight] [decimal](9, 2) NULL,
	[WeightKg] [decimal](9, 2) NULL,
	[WhWheelCod1] [nchar](50) NULL,
	[WhWheelCod2] [nchar](50) NULL,
	[TyEcoNoiseLev2] [nvarchar](50) NULL,
 CONSTRAINT [PK_dbo.Products] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

SET ANSI_PADDING ON
GO

/****** Object:  Index [IX_Products_Manuf]    Script Date: 09/04/2026 17:55:04 ******/
CREATE NONCLUSTERED INDEX [IX_Products_Manuf] ON [dbo].[Products]
(
	[BrandId] ASC,
	[ManufacturerCod] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO

SET ANSI_PADDING ON
GO

/****** Object:  Index [IX_Products_ProductType_AcB_Brand_ManufacturerCod]    Script Date: 09/04/2026 17:55:04 ******/
CREATE NONCLUSTERED INDEX [IX_Products_ProductType_AcB_Brand_ManufacturerCod] ON [dbo].[Products]
(
	[ProductTypeId] ASC,
	[AcBTypeId] ASC,
	[BrandId] ASC,
	[ManufacturerCod] ASC
)
INCLUDE([Id],[Descr]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO


