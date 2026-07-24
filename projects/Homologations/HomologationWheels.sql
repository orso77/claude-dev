USE [WheelsNet]
GO

/****** Object:  Table [dbo].[HomologationWheels]    Script Date: 3/30/2026 10:33:32 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[HomologationWheels](
	[VehicleModelId] [int] NOT NULL,
	[WheelHomolCode] [varchar](50) NOT NULL,
	[WheelManufacturerCode] [varchar](50) NOT NULL,
	[Homologation] [varchar](255) NOT NULL,
	[HomologationCode] [varchar](255) NOT NULL,
	[HomologationAxles] [varchar](50) NOT NULL,
	[HomologationKtypes] [varchar](max) NOT NULL,
	[HomologationNotes] [varchar](max) NOT NULL,
	[HomologationFiles] [varchar](max) NOT NULL,
	[HomologationTyres] [varchar](max) NOT NULL,
	[HomologationTyreNotes] [varchar](max) NOT NULL,
	[HasInterchangeableOeCup] [bit] NOT NULL,
	[UseOeFasteners] [bit] NOT NULL,
	[OnlyForOeSteelWheels] [bit] NOT NULL,
	[HasBrakeWarning] [bit] NOT NULL,
	[KitsetBrandId] [varchar](50) NOT NULL,
	[KitsetManufacturerCode] [varchar](50) NOT NULL,
	[Timestamp] [datetime] NOT NULL,
 CONSTRAINT [PK_HomologationWheels] PRIMARY KEY CLUSTERED 
(
	[VehicleModelId] ASC,
	[WheelHomolCode] ASC,
	[WheelManufacturerCode] ASC,
	[Homologation] ASC,
	[HomologationCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO