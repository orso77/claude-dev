USE [WheelSystems]
GO

/****** Object:  Table [dbo].[WhVersions]    Script Date: 09/04/2026 17:57:43 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[WhVersions](
	[Id] [int] NOT NULL,
	[Cod] [varchar](50) NULL,
	[ProductModelId] [int] NULL,
	[Descr] [nvarchar](max) NULL,
	[Holes] [int] NULL,
	[WhColorId] [int] NULL,
 CONSTRAINT [PK_dbo.WhVersions] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO


