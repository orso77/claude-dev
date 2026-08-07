/* =============================================================================
   Backup di SpStock_356V008_Nsk prima dell'aggiunta degli accessori NSK
   (INSERT da SpAutPriceAccessories + fallback descrittivo su Accessories).

   Fotografa la versione corrente (gia' comprensiva dei campi Spares aggiunti
   il 2026-08-07 mattina); il backup _202608071330 conserva invece la versione
   precedente a quell'aggiunta.
   Idempotente: se la copia esiste gia' non fa nulla.

   Target: 192.168.100.52 (produzione) - WheelSystemsExport
   ============================================================================= */
USE [WheelSystemsExport];
GO

DECLARE @name    sysname = N'SpStock_356V008_Nsk';
DECLARE @bakName sysname = N'SpStock_356V008_Nsk_202608071805';
DECLARE @sql     nvarchar(max);

IF OBJECT_ID(N'dbo.' + @name, N'P') IS NULL
    PRINT 'MISSING SOURCE: dbo.' + @name;
ELSE IF OBJECT_ID(N'dbo.' + @bakName, N'P') IS NOT NULL
    PRINT 'ALREADY EXISTS: dbo.' + @bakName;
ELSE
BEGIN
    SET @sql = OBJECT_DEFINITION(OBJECT_ID(N'dbo.' + @name));
    SET @sql = REPLACE(@sql, N'[' + @name + N']', N'[' + @bakName + N']');
    EXEC sp_executesql @sql;
    PRINT 'CREATED: dbo.' + @bakName;
END
GO
