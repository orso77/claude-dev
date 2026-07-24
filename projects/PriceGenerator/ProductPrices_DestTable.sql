USE [WheelsNet]
GO

/****** Object:  Table [dbo].[ProductPrices]    Script Date: 3/30/2026 10:16:59 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[ProductPrices](
	[ProductId] [varchar](50) NOT NULL,
	[ListPrice] [decimal](18, 4) NOT NULL,
	[TopPrice01In] [decimal](18, 4) NOT NULL,
	[TopPrice01Out] [decimal](18, 4) NOT NULL,
	[TopPrice02In] [decimal](18, 4) NOT NULL,
	[TopPrice02Out] [decimal](18, 4) NOT NULL,
	[TopPrice03In] [decimal](18, 4) NOT NULL,
	[TopPrice03Out] [decimal](18, 4) NOT NULL,
	[TopPrice04In] [decimal](18, 4) NOT NULL,
	[TopPrice04Out] [decimal](18, 4) NOT NULL,
	[TopPrice05In] [decimal](18, 4) NOT NULL,
	[TopPrice05Out] [decimal](18, 4) NOT NULL,
	[TopPrice06In] [decimal](18, 4) NOT NULL,
	[TopPrice06Out] [decimal](18, 4) NOT NULL,
	[TopPrice07In] [decimal](18, 4) NOT NULL,
	[TopPrice07Out] [decimal](18, 4) NOT NULL,
	[TopPrice08In] [decimal](18, 4) NOT NULL,
	[TopPrice08Out] [decimal](18, 4) NOT NULL,
	[TopPrice09In] [decimal](18, 4) NOT NULL,
	[TopPrice09Out] [decimal](18, 4) NOT NULL,
	[TopPrice10In] [decimal](18, 4) NOT NULL,
	[TopPrice10Out] [decimal](18, 4) NOT NULL,
	[RevPrice01In] [decimal](18, 4) NOT NULL,
	[RevPrice01Out] [decimal](18, 4) NOT NULL,
	[RevPrice02In] [decimal](18, 4) NOT NULL,
	[RevPrice02Out] [decimal](18, 4) NOT NULL,
	[RevPrice03In] [decimal](18, 4) NOT NULL,
	[RevPrice03Out] [decimal](18, 4) NOT NULL,
	[RevPrice04In] [decimal](18, 4) NOT NULL,
	[RevPrice04Out] [decimal](18, 4) NOT NULL,
	[RevPrice05In] [decimal](18, 4) NOT NULL,
	[RevPrice05Out] [decimal](18, 4) NOT NULL,
	[RevPrice06In] [decimal](18, 4) NOT NULL,
	[RevPrice06Out] [decimal](18, 4) NOT NULL,
	[RevPrice07In] [decimal](18, 4) NOT NULL,
	[RevPrice07Out] [decimal](18, 4) NOT NULL,
	[RevPrice08In] [decimal](18, 4) NOT NULL,
	[RevPrice08Out] [decimal](18, 4) NOT NULL,
	[RevPrice09In] [decimal](18, 4) NOT NULL,
	[RevPrice09Out] [decimal](18, 4) NOT NULL,
	[RevPrice10In] [decimal](18, 4) NOT NULL,
	[RevPrice10Out] [decimal](18, 4) NOT NULL,
	[AutPrice01In] [decimal](18, 4) NOT NULL,
	[AutPrice01Out] [decimal](18, 4) NOT NULL,
	[AutPrice02In] [decimal](18, 4) NOT NULL,
	[AutPrice02Out] [decimal](18, 4) NOT NULL,
	[AutPrice03In] [decimal](18, 4) NOT NULL,
	[AutPrice03Out] [decimal](18, 4) NOT NULL,
	[AutPrice04In] [decimal](18, 4) NOT NULL,
	[AutPrice04Out] [decimal](18, 4) NOT NULL,
	[AutPrice05In] [decimal](18, 4) NOT NULL,
	[AutPrice05Out] [decimal](18, 4) NOT NULL,
	[AutPrice06In] [decimal](18, 4) NOT NULL,
	[AutPrice06Out] [decimal](18, 4) NOT NULL,
	[AutPrice07In] [decimal](18, 4) NOT NULL,
	[AutPrice07Out] [decimal](18, 4) NOT NULL,
	[AutPrice08In] [decimal](18, 4) NOT NULL,
	[AutPrice08Out] [decimal](18, 4) NOT NULL,
	[AutPrice09In] [decimal](18, 4) NOT NULL,
	[AutPrice09Out] [decimal](18, 4) NOT NULL,
	[AutPrice10In] [decimal](18, 4) NOT NULL,
	[AutPrice10Out] [decimal](18, 4) NOT NULL,
	[Timestamp] [datetime] NOT NULL,
 CONSTRAINT [PK_ProductPrices] PRIMARY KEY CLUSTERED 
(
	[ProductId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[ProductPrices] ADD  CONSTRAINT [DF_ProductPrices_Timestamp]  DEFAULT (getdate()) FOR [Timestamp]
GO

