/*
    WheelsNet.dbo.ViewNtsSyncTyres
    ------------------------------
    Sorgente PNEUMATICI in formato srvsql.dbtopruote.dbo.artico (ditta TOPRUOTE).
    Usata da dbo.SpNtsArticoUpsertTyres.

    NOTE
    > Non applica alcun filtro su PubblicationTypes: se l'articolo esiste in
      dbo.Tyres deve poter andare nell'ERP (decisione utente).
    > Non espone ar_datins / ar_orins / ar_ultagg / ar_oragg: sono valori
      per-esecuzione e li calcola la stored.
    > I fallback peso per diametro sono ripresi da dbo.ViewNtsSyncProducts.

    TEST:
        SELECT * FROM dbo.ViewNtsSyncTyres WHERE ar_codart = 'ZZ00000849390';
*/
CREATE OR ALTER VIEW dbo.ViewNtsSyncTyres
AS

SELECT
    -- chiave
     codditt              = CAST('TOPRUOTE' AS VARCHAR(12))
    ,ar_codart            = CAST(t.Id AS VARCHAR(50))

    -- descrizione (convenzione NTS: 40 + 40 caratteri)
    ,ar_descr             = CAST(LEFT(t.Descr, 40) AS VARCHAR(255))
    ,ar_desint            = CAST(SUBSTRING(t.Descr, 41, 40) AS VARCHAR(40))

    -- codici alternativi: NULL quando la sorgente non ha un valore reale
    ,ar_codalt            =
        CAST(CASE
            WHEN LTRIM(RTRIM(t.ManufacturerCode)) = ''  THEN NULL
            WHEN t.ManufacturerCode = t.Id              THEN NULL   -- placeholder, non un codice fornitore
            ELSE LTRIM(RTRIM(t.ManufacturerCode))
        END AS VARCHAR(50))
    ,ar_hhean             =
        CAST(CASE
            WHEN LTRIM(RTRIM(t.Ean)) = ''  THEN NULL
            WHEN t.Ean = t.Id              THEN NULL   -- placeholder, non un EAN
            ELSE LTRIM(RTRIM(t.Ean))
        END AS VARCHAR(50))

    -- classificazione
    ,ar_gruppo            = CAST(2 AS SMALLINT)
    ,ar_sotgru            = CAST(201 AS SMALLINT)
    ,ar_claprov           = CAST(2 AS SMALLINT)
    ,ar_controp           = CAST(5369 AS SMALLINT)
    ,ar_controa           = CAST(5373 AS SMALLINT)
    ,ar_famprod           = CAST(t.BrandId AS VARCHAR(4))
    ,ar_codnomc           = CAST('4011.10.00' AS VARCHAR(10))

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
    -- Sono decimal(27,9), quindi il valore va scritto raw.
    ,ar_pesonet           = CAST(p.peso AS DECIMAL(27,9))
    ,ar_pesolor           = CAST(p.peso AS DECIMAL(27,9))

    -- [SCALA] misure: k.scala vale 100. Vedi il blocco FROM in fondo.
    ,ar_pnmis             = CAST(t.Width    * k.scala AS DECIMAL(18,0))
    ,ar_pnspal            = CAST(t.AspRatio * k.scala AS DECIMAL(18,0))
    ,ar_pndiam            = CAST(t.Diameter * k.scala AS DECIMAL(18,0))

    -- attributi pneumatico (ar_pnindcar non e' mai scalato)
    ,ar_pnindcar          = CAST(t.LoadIdx1 AS INT)
    ,ar_pncodvel          = CAST(LEFT(t.SpeedId, 2) AS VARCHAR(2))
    ,ar_pnsotgrup         = CAST(t.Category AS VARCHAR(255))
    ,ar_pnstag            =
        CAST(CASE UPPER(t.Season)
            WHEN 'SUMMER'    THEN 'summer'
            WHEN 'WINTER'    THEN 'winter'
            WHEN '4 SEASONS' THEN '4season'
            ELSE ''
        END AS VARCHAR(255))
    ,ar_pndot             = CAST(t.Dot AS INT)
    ,ar_pneupresistrot    = CAST(LEFT(t.EcoRollResist, 1) AS VARCHAR(1))
    ,ar_pneupaderbagn     = CAST(LEFT(t.EcoWetGrip, 1) AS VARCHAR(1))
    ,ar_pneuprumordb      = CAST(t.EcoNoiseDb AS DECIMAL(18,0))
    ,ar_pneuprumorliv     = CAST(t.EcoNoiseLev AS DECIMAL(18,0))
    ,ar_pneuprumorliv2    = CAST(t.EcoNoiseLev2 AS VARCHAR(50))
    ,ar_pnrating          = CAST(0 AS DECIMAL(18,0))
    ,ar_pndemo            = CAST(CASE WHEN t.Demo = 1 THEN 'S' ELSE 'N' END AS VARCHAR(1))

FROM dbo.Tyres t

-- ============================================================================
-- [SCALA] 100 = scala ERP storica, nessuna perdita di informazione.
-- Le colonne ar_pn* di artico sono decimal(18,0), cioe' INTERI: 215/65R17,5
-- diventa 21500 / 6500 / 1750. Con scala 1 i decimali verrebbero arrotondati
-- (17,50" -> 18 su 628 pneumatici, piu' 101 larghezze e 221 spalle), percio'
-- la scala 1 NON e' utilizzabile. E' anche il formato del 97,8% delle righe
-- gia' presenti in artico e del 100% di quelle create di recente.
-- ============================================================================
CROSS JOIN (SELECT scala = CAST(100 AS DECIMAL(5,0))) k

-- fallback peso per diametro (da ViewNtsSyncProducts)
CROSS APPLY (
    SELECT pesoDefault =
        CASE
            WHEN t.Diameter <= 14 THEN 6
            WHEN t.Diameter  = 15 THEN 7
            WHEN t.Diameter  = 16 THEN 8
            WHEN t.Diameter  = 17 THEN 11
            WHEN t.Diameter  = 18 THEN 12
            WHEN t.Diameter  = 19 THEN 13
            WHEN t.Diameter  = 20 THEN 14
            WHEN t.Diameter  = 21 THEN 15
            WHEN t.Diameter >= 22 THEN 18
            ELSE 21
        END
) d
CROSS APPLY (
    SELECT peso = CASE WHEN t.NetWeightKg > 0 THEN t.NetWeightKg ELSE d.pesoDefault END
) p

WHERE t.ProductTypeId = 2;
