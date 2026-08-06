/*
    WheelsNet.dbo.ViewNtsSyncWheels
    -------------------------------
    Sorgente CERCHI in formato srvsql.dbtopruote.dbo.artico (ditta TOPRUOTE).
    Usata da dbo.SpNtsArticoUpsertWheels.

    NOTE
    > ProductTypeId 4 (lega) -> gruppo 4 / sotgru 401 / controp 5370 / controa 5374
      ProductTypeId 8 (ferro) -> gruppo 8 / sotgru 801 / controp 5371 / controa 5375
    > ar_cersotgrup e ar_cermarcveic1 sono esposti col valore dominante in ERP,
      ma la stored li scrive SOLO in INSERT: in UPDATE non si toccano.
    > Nessun filtro su PubblicationTypes.

    TEST:
        SELECT * FROM dbo.ViewNtsSyncWheels WHERE ar_codart = 'CL00000457062';
*/
CREATE OR ALTER VIEW dbo.ViewNtsSyncWheels
AS

SELECT
    -- chiave
     codditt              = CAST('TOPRUOTE' AS VARCHAR(12))
    ,ar_codart            = CAST(w.Id AS VARCHAR(50))

    -- descrizione (convenzione NTS: 40 + 40 caratteri)
    ,ar_descr             = CAST(LEFT(w.Descr, 40) AS VARCHAR(255))
    ,ar_desint            = CAST(SUBSTRING(w.Descr, 41, 40) AS VARCHAR(40))

    -- codici alternativi: NULL quando la sorgente non ha un valore reale
    ,ar_codalt            =
        CAST(CASE
            WHEN LTRIM(RTRIM(w.ManufacturerCode)) = ''  THEN NULL
            WHEN w.ManufacturerCode = w.Id              THEN NULL   -- placeholder, non un codice fornitore
            ELSE LTRIM(RTRIM(w.ManufacturerCode))
        END AS VARCHAR(50))
    ,ar_hhean             =
        CAST(CASE
            WHEN LTRIM(RTRIM(w.Ean)) = ''  THEN NULL
            WHEN w.Ean = w.Id              THEN NULL   -- placeholder, non un EAN
            ELSE LTRIM(RTRIM(w.Ean))
        END AS VARCHAR(50))

    -- classificazione
    ,ar_gruppo            = CAST(w.ProductTypeId AS SMALLINT)
    ,ar_sotgru            = CAST(CASE w.ProductTypeId WHEN 4 THEN 401  ELSE 801  END AS SMALLINT)
    ,ar_claprov           = CAST(w.ProductTypeId AS SMALLINT)
    ,ar_controp           = CAST(CASE w.ProductTypeId WHEN 4 THEN 5370 ELSE 5371 END AS SMALLINT)
    ,ar_controa           = CAST(CASE w.ProductTypeId WHEN 4 THEN 5374 ELSE 5375 END AS SMALLINT)
    ,ar_famprod           = CAST(w.BrandId AS VARCHAR(4))
    ,ar_codnomc           = CAST(CASE w.ProductTypeId WHEN 4 THEN '8708.70.50' ELSE '8708.70.91' END AS VARCHAR(10))

    -- costanti di sistema (le altre arrivano dai default constraint di artico)
    ,ar_unmis             = CAST('NR' AS VARCHAR(3))
    ,ar_conver            = CAST(1 AS DECIMAL(27,9))
    ,ar_qtacon2           = CAST(1 AS DECIMAL(27,9))
    ,ar_codiva            = CAST(122 AS SMALLINT)
    ,ar_contros           = CAST(1006 AS SMALLINT)
    ,ar_prorig            = CAST('MC' AS VARCHAR(2))
    ,ar_paeorig           = CAST('IT' AS VARCHAR(3))
    ,ar_paeorigv          = CAST('IT' AS VARCHAR(3))
    ,ar_umintra2          = CAST('P' AS VARCHAR(1))

    -- pesi: ar_pesolor = ar_pesonet. In artico i due campi sono identici su
    -- tutte e 245.075 le righe e SpNtsArticoUpdate li allinea gia' cosi'.
    -- GrossWeightKg NON viene propagato: e' maggiore del netto su 76.795
    -- cerchi su 82.413 e introdurrebbe una differenza mai esistita in ERP.
    ,ar_pesonet           = CAST(p.peso AS DECIMAL(27,9))
    ,ar_pesolor           = CAST(p.peso AS DECIMAL(27,9))

    -- [SCALA] misure: k.scala vale 100. Vedi il blocco FROM in fondo.
    ,ar_cermis            = CAST(w.Width       * k.scala AS DECIMAL(18,0))
    ,ar_cerdiam           = CAST(w.Diameter    * k.scala AS DECIMAL(18,0))
    ,ar_cerinter1         = CAST(w.Pcd1        * k.scala AS DECIMAL(18,0))
    ,ar_cerinter2         = CAST(w.Pcd2        * k.scala AS DECIMAL(18,0))
    ,ar_cerinter3         = CAST(w.Pcd3        * k.scala AS DECIMAL(18,0))
    ,ar_ceret             = CAST(w.[Offset]    * k.scala AS DECIMAL(18,0))
    ,ar_cerformax         = CAST(w.MaxBoreDiam * k.scala AS DECIMAL(18,0))

    -- attributi cerchio (ar_cerfor non e' mai scalato)
    ,ar_cerfor            = CAST(w.Holes AS INT)
    ,ar_cercolor          = CAST(w.Color AS VARCHAR(255))

    -- default applicati SOLO in INSERT dalla stored (valori dominanti in ERP)
    ,ar_cersotgrup        = CAST('AUTOVETTURA' AS VARCHAR(255))
    ,ar_cermarcveic1      = CAST('CATALOGO' AS VARCHAR(255))

FROM dbo.Wheels w

-- ============================================================================
-- [SCALA] 100 = scala ERP storica, nessuna perdita di informazione.
-- Le colonne ar_cer* di artico sono decimal(18,0), cioe' INTERI: NTS ci
-- convive memorizzando il valore moltiplicato per 100. Verificato sul dato
-- reale: Pcd1 114,30 -> ar_cerinter1 11430, Width 6,50 -> ar_cermis 650,
-- MaxBoreDiam 67,00 -> ar_cerformax 6700.
-- Con scala 1 si perderebbero i decimali di 71.448 cerchi su 82.413
-- (MaxBoreDiam) e di 35.888 (mezza misura di canale), quindi NON e' usabile.
-- ============================================================================
CROSS JOIN (SELECT scala = CAST(100 AS DECIMAL(5,0))) k

-- fallback peso per diametro (da ViewNtsSyncProducts)
CROSS APPLY (
    SELECT pesoDefault =
        CASE
            WHEN w.Diameter <= 14 THEN 5
            WHEN w.Diameter  = 15 THEN 5
            WHEN w.Diameter  = 16 THEN 5
            WHEN w.Diameter  = 17 THEN 6
            WHEN w.Diameter  = 18 THEN 7
            WHEN w.Diameter  = 19 THEN 9
            WHEN w.Diameter  = 20 THEN 9
            WHEN w.Diameter  = 21 THEN 11
            WHEN w.Diameter  = 22 THEN 12
            WHEN w.Diameter >= 23 THEN 15
            ELSE 10
        END
) d
CROSS APPLY (
    SELECT peso = CASE WHEN w.NetWeightKg > 0 THEN w.NetWeightKg ELSE d.pesoDefault END
) p

WHERE w.ProductTypeId IN (4, 8);
