-- Genera gli statement di backup per tutte le tabelle del DB
-- Esclude:
--   - tabelle di backup che terminano per _YYYYMMddHHmm (underscore + 12 cifre)
--   - tabelle che iniziano per zzz_
--   - tabelle che iniziano per _
-- Output: una colonna 'Stmt' con i comandi da copiare ed eseguire.

DECLARE @ts CHAR(12) = FORMAT(GETDATE(), 'yyyyMMddHHmm');

SELECT
     Stmt =
        'SELECT * INTO '
        + QUOTENAME(SCHEMA_NAME(t.schema_id)) + '.' + QUOTENAME(t.name + '_' + @ts)
        + ' FROM '
        + QUOTENAME(SCHEMA_NAME(t.schema_id)) + '.' + QUOTENAME(t.name) + ';'
FROM sys.tables t
WHERE t.is_ms_shipped = 0
  AND t.name NOT LIKE 'zzz[_]%'
  AND t.name NOT LIKE '[_]%'
  AND t.name NOT LIKE '%[_][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
ORDER BY SCHEMA_NAME(t.schema_id), t.name;
