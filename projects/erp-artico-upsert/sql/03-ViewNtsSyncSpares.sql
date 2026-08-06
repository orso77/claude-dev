/*
    WheelsNet.dbo.ViewNtsSyncSpares
    -------------------------------
    Sorgente RICAMBI / RUOTINI in formato srvsql.dbtopruote.dbo.artico (ditta TOPRUOTE).
    Usata da dbo.SpNtsArticoUpsertSpares.

    NOTE
    > ar_sotgru = 1600 + ProductSubTypeId. Oggi tutte e 3.163 le righe di
      dbo.Spares hanno ProductSubTypeId = 69 (RUOTINO EMERGENZA), quindi il
      valore prodotto e' 1669 -- lo stesso su cui stanno le 5.618 righe gia'
      presenti in artico. Il calcolo resta valido se in futuro nascono altri
      sottotipi di ricambio.
    > In artico i ricambi hanno oggi le ar_cer* a zero: popolarle e' un
      miglioramento voluto, non un allineamento all'esistente.
    > Nessun filtro su PubblicationTypes.

    TEST:
        SELECT * FROM dbo.ViewNtsSyncSpares WHERE ar_codart = 'RUNUVKRL0001A';
*/
CREATE OR ALTER VIEW dbo.ViewNtsSyncSpares
AS

SELECT
    -- chiave
     codditt              = CAST('TOPRUOTE' AS VARCHAR(12))
    ,ar_codart            = CAST(s.Id AS VARCHAR(50))

    -- descrizione (convenzione NTS: 40 + 40 caratteri)
    ,ar_descr             = CAST(LEFT(s.Descr, 40) AS VARCHAR(255))
    ,ar_desint            = CAST(SUBSTRING(s.Descr, 41, 40) AS VARCHAR(40))

    -- codici alternativi: NULL quando la sorgente non ha un valore reale
    ,ar_codalt            =
        CAST(CASE
            WHEN LTRIM(RTRIM(s.ManufacturerCode)) = ''  THEN NULL
            WHEN s.ManufacturerCode = s.Id              THEN NULL   -- placeholder, non un codice fornitore
            ELSE LTRIM(RTRIM(s.ManufacturerCode))
        END AS VARCHAR(50))
    ,ar_hhean             =
        CAST(CASE
            WHEN LTRIM(RTRIM(s.Ean)) = ''  THEN NULL
            WHEN s.Ean = s.Id              THEN NULL   -- placeholder, non un EAN
            ELSE LTRIM(RTRIM(s.Ean))
        END AS VARCHAR(50))

    -- classificazione
    ,ar_gruppo            = CAST(16 AS SMALLINT)
    ,ar_sotgru            = CAST(1600 + ISNULL(s.ProductSubTypeId, 69) AS SMALLINT)
    ,ar_claprov           = CAST(16 AS SMALLINT)
    ,ar_controp           = CAST(5372 AS SMALLINT)
    ,ar_controa           = CAST(5376 AS SMALLINT)
    ,ar_famprod           = CAST(s.BrandId AS VARCHAR(4))
    ,ar_codnomc           = CAST(CASE s.ProductSubTypeId
                                     WHEN 21 THEN '8708.70.50'   -- ruotino con cerchio in lega
                                     ELSE         '8708.70.91'
                                 END AS VARCHAR(10))
    ,ar_accsotgrup        = CAST(pst.Descr AS VARCHAR(255))

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
    -- GrossWeightKg NON viene propagato: e' maggiore del netto su tutti e
    -- 3.163 i ricambi e introdurrebbe una differenza mai esistita in ERP.
    ,ar_pesonet           = CAST(p.peso AS DECIMAL(27,9))
    ,ar_pesolor           = CAST(p.peso AS DECIMAL(27,9))

    -- [SCALA] misure: k.scala vale 100. Vedi il blocco FROM in fondo.
    ,ar_cermis            = CAST(s.Width    * k.scala AS DECIMAL(18,0))
    ,ar_cerdiam           = CAST(s.Diameter * k.scala AS DECIMAL(18,0))
    ,ar_cerinter1         = CAST(s.Pcd1     * k.scala AS DECIMAL(18,0))
    ,ar_pndiam            = CAST(s.Diameter * k.scala AS DECIMAL(18,0))

    -- attributi (ar_cerfor non e' mai scalato)
    ,ar_cerfor            = CAST(s.Holes AS INT)

FROM dbo.Spares s
LEFT JOIN dbo.ProductSubTypes pst
    ON  pst.ProductTypeId = s.ProductTypeId
    AND pst.Id            = s.ProductSubTypeId

-- ============================================================================
-- [SCALA] 100 = scala ERP storica, nessuna perdita di informazione.
-- Le colonne ar_cer* / ar_pndiam di artico sono decimal(18,0), cioe' INTERI:
-- NTS ci convive memorizzando il valore moltiplicato per 100 (Pcd1 114,30 ->
-- 11430). Oggi in dbo.Spares non ci sono misure con decimali, ma la scala e'
-- tenuta uguale alle altre tipologie per coerenza dell'anagrafica.
-- ============================================================================
CROSS JOIN (SELECT scala = CAST(100 AS DECIMAL(5,0))) k

-- fallback peso per diametro (da ViewNtsSyncProducts)
CROSS APPLY (
    SELECT pesoDefault =
        CASE
            WHEN s.Diameter <= 14 THEN 14
            WHEN s.Diameter  = 15 THEN 15
            WHEN s.Diameter  = 16 THEN 16
            WHEN s.Diameter  = 17 THEN 19
            WHEN s.Diameter  = 18 THEN 20
            WHEN s.Diameter  = 19 THEN 22
            WHEN s.Diameter  > 19 THEN 25
            ELSE 15
        END
) d
CROSS APPLY (
    SELECT peso = CASE WHEN s.NetWeightKg > 0 THEN s.NetWeightKg ELSE d.pesoDefault END
) p

WHERE s.ProductTypeId = 16;
