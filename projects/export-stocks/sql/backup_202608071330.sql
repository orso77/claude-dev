/* =============================================================================
   Backup stored procedure stock 356 prima dell'aggiunta dei campi Spares
   (Img1..Img5, Width, Diameter, Holes, Pcd1, MadeIn, NetWeightKg, GrossWeightKg,
    MaxLoad, Tyre, BoxSize, Material, TrunkSize).

   Crea una copia identica di ogni SP con suffisso _202608071330, secondo la
   convenzione gia' in uso nel DB (es. SpStock_RevorimV001_202604201100).
   Idempotente: se la copia esiste gia' non fa nulla.

   Target: 192.168.100.52 (produzione) - WheelSystemsExport
   ============================================================================= */
USE [WheelSystemsExport];
GO

DECLARE @suffix   sysname = N'_202608071330';
DECLARE @name     sysname;
DECLARE @bakName  sysname;
DECLARE @sql      nvarchar(max);

DECLARE cur CURSOR LOCAL FAST_FORWARD FOR
    SELECT N'SpStock_356NuvolariV001'
    UNION ALL SELECT N'SpStock_356V001'
    UNION ALL SELECT N'SpStock_356V008_Nsk';

OPEN cur;
FETCH NEXT FROM cur INTO @name;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @bakName = @name + @suffix;

    IF OBJECT_ID(N'dbo.' + @name, N'P') IS NULL
    BEGIN
        PRINT 'MISSING SOURCE: dbo.' + @name;
    END
    ELSE IF OBJECT_ID(N'dbo.' + @bakName, N'P') IS NOT NULL
    BEGIN
        PRINT 'ALREADY EXISTS: dbo.' + @bakName;
    END
    ELSE
    BEGIN
        SET @sql = OBJECT_DEFINITION(OBJECT_ID(N'dbo.' + @name));
        SET @sql = REPLACE(@sql, N'[' + @name + N']', N'[' + @bakName + N']');
        EXEC sp_executesql @sql;
        PRINT 'CREATED: dbo.' + @bakName;
    END

    FETCH NEXT FROM cur INTO @name;
END

CLOSE cur;
DEALLOCATE cur;
GO
