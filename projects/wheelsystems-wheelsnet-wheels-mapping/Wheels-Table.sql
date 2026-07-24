USE [WheelsNet]
GO

/****** Object:  Table [dbo].[Wheels]    Script Date: 09/04/2026 17:59:45 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Wheels](
	[Id] [varchar](50) NOT NULL,
	[Descr] [varchar](255) NOT NULL,
	[DescrEn] [varchar](255) NOT NULL,
	[ProductTypeId] [int] NOT NULL,
	[ProductType] [varchar](255) NULL,
	[ProductTypeEn] [varchar](255) NULL,
	[PubblicationTypes] [bigint] NOT NULL,
	[BrandId] [varchar](50) NOT NULL,
	[Ean] [varchar](50) NOT NULL,
	[ManufacturerCode] [varchar](50) NOT NULL,
	[MaterialId] [int] NULL,
	[Ext_HomolCode]  AS (coalesce(nullif([HomolCode1],''),[HomolCode2],'')),
	[HomolCode1] [varchar](50) NOT NULL,
	[HomolCode2] [varchar](50) NOT NULL,
	[Model] [varchar](255) NOT NULL,
	[VersionCode] [varchar](50) NOT NULL,
	[Version] [varchar](255) NOT NULL,
	[Img1] [varchar](255) NOT NULL,
	[Img2] [varchar](255) NOT NULL,
	[Img3] [varchar](255) NOT NULL,
	[Img4] [varchar](255) NOT NULL,
	[Img5] [varchar](255) NOT NULL,
	[Width] [decimal](12, 2) NOT NULL,
	[Diameter] [decimal](12, 2) NOT NULL,
	[Holes] [int] NOT NULL,
	[Pcd1] [decimal](12, 2) NOT NULL,
	[Pcd2] [decimal](12, 2) NOT NULL,
	[Pcd3] [decimal](12, 2) NOT NULL,
	[Offset] [decimal](12, 2) NOT NULL,
	[MinBoreDiam] [decimal](12, 2) NOT NULL,
	[MaxBoreDiam] [decimal](12, 2) NOT NULL,
	[IntHeft] [decimal](12, 2) NOT NULL,
	[ExtHeft] [decimal](12, 2) NOT NULL,
	[ColorCode] [varchar](50) NOT NULL,
	[Color] [varchar](50) NOT NULL,
	[MadeIn] [varchar](50) NOT NULL,
	[Profile] [varchar](50) NOT NULL,
	[BoltSeat] [varchar](50) NOT NULL,
	[NetWeightKg] [decimal](12, 2) NOT NULL,
	[GrossWeightKg] [decimal](12, 2) NOT NULL,
	[MaxLoad] [decimal](12, 2) NOT NULL,
	[Cup] [varchar](50) NOT NULL,
	[CupOe] [varchar](50) NOT NULL,
	[Lens] [varchar](50) NOT NULL,
	[Ece] [varchar](50) NOT NULL,
	[Nad] [varchar](50) NOT NULL,
	[Kba] [varchar](50) NOT NULL,
	[Timestamp] [datetime] NOT NULL,
 CONSTRAINT [PK_Wheels] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

SET ARITHABORT ON
SET CONCAT_NULL_YIELDS_NULL ON
SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
SET NUMERIC_ROUNDABORT OFF
GO

/****** Object:  Index [IX_Wheels_Ext_HomolCode]    Script Date: 09/04/2026 17:59:45 ******/
CREATE NONCLUSTERED INDEX [IX_Wheels_Ext_HomolCode] ON [dbo].[Wheels]
(
	[Ext_HomolCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO

SET ANSI_PADDING ON
GO

/****** Object:  Index [IX_Wheels_Filtering]    Script Date: 09/04/2026 17:59:45 ******/
CREATE NONCLUSTERED INDEX [IX_Wheels_Filtering] ON [dbo].[Wheels]
(
	[BrandId] ASC
)
INCLUDE([Model],[Color],[Diameter],[Width],[Offset],[Holes],[Pcd1],[MaxBoreDiam],[Img1]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO

SET ANSI_PADDING ON
GO

/****** Object:  Index [IX_Wheels_HomolCode1]    Script Date: 09/04/2026 17:59:45 ******/
CREATE NONCLUSTERED INDEX [IX_Wheels_HomolCode1] ON [dbo].[Wheels]
(
	[HomolCode1] ASC
)
INCLUDE([BrandId],[ProductTypeId],[Id],[Ean],[ColorCode],[Img1],[Img3],[ManufacturerCode],[Descr],[Width],[Diameter],[Version],[Pcd1],[Model],[VersionCode],[Offset],[MaxBoreDiam],[Img2],[Color],[Img4],[Img5],[Pcd2],[Pcd3],[Holes]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO

SET ANSI_PADDING ON
GO

/****** Object:  Index [IX_Wheels_HomolCode2]    Script Date: 09/04/2026 17:59:45 ******/
CREATE NONCLUSTERED INDEX [IX_Wheels_HomolCode2] ON [dbo].[Wheels]
(
	[HomolCode2] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO

SET ANSI_PADDING ON
GO

/****** Object:  Index [IX_Wheels_ProductId]    Script Date: 09/04/2026 17:59:45 ******/
CREATE NONCLUSTERED INDEX [IX_Wheels_ProductId] ON [dbo].[Wheels]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Wheels] ADD  CONSTRAINT [DF_Wheels_ImgName2]  DEFAULT ('') FOR [Img2]
GO

ALTER TABLE [dbo].[Wheels] ADD  CONSTRAINT [DF_Wheels_ImgName3]  DEFAULT ('') FOR [Img3]
GO

ALTER TABLE [dbo].[Wheels] ADD  CONSTRAINT [DF_Wheels_ImgName4]  DEFAULT ('') FOR [Img4]
GO

ALTER TABLE [dbo].[Wheels] ADD  CONSTRAINT [DF_Wheels_ImgName5]  DEFAULT ('') FOR [Img5]
GO

ALTER TABLE [dbo].[Wheels] ADD  CONSTRAINT [DF_Wheels_Timestamp]  DEFAULT (getdate()) FOR [Timestamp]
GO


