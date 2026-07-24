/* =============================================================================
   WheelSystemsExport.dbo.FnDecimalFormat2
   Formatta un decimale a 2 cifre con virgola decimale, MANTENENDO lo zero (0,00).
   Differisce da dbo.FnDecimalFormat, che per val=0 ritorna stringa vuota.
   Usato dagli export stock 356 (Stock1/Stock2/ListPrice/PfuEuroNoVat/pesi/incoming).
   Cultura 'en-US' esplicita per determinismo del separatore, poi '.' -> ','.
   ============================================================================= */
USE [WheelSystemsExport];
GO

CREATE OR ALTER FUNCTION [dbo].[FnDecimalFormat2](@val decimal(18,4))
RETURNS varchar(40)
AS
BEGIN
    RETURN REPLACE(FORMAT(ISNULL(@val, 0), '0.00', 'en-US'), '.', ',');
END
GO
