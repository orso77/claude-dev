USE [WheelSystems]
GO

/****** Object:  Table [dbo].[ProductModels]    Script Date: 09/04/2026 17:56:46 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[ProductModels](
	[Id] [int] NOT NULL,
	[RowState] [int] NOT NULL,
	[InsDate] [datetime] NOT NULL,
	[InsUserId] [int] NULL,
	[UpdDate] [datetime] NOT NULL,
	[UpdUserId] [int] NULL,
	[BrandId] [int] NOT NULL,
	[Descr] [nvarchar](max) NOT NULL,
	[ExtendedDescr] [nvarchar](max) NULL,
	[ProductTypeId] [int] NOT NULL,
	[TyTypeId] [int] NULL,
	[TySeasonId] [int] NULL,
	[TyManufactureTypeId] [nchar](1) NULL,
	[WhSpokes] [int] NULL,
	[WhManufactureTypeId] [int] NULL,
	[WhManufacturePieces] [int] NULL,
 CONSTRAINT [PK_dbo.ProductModels] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO


