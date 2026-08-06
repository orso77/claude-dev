/*
    WheelsNet.dbo.ViewNtsSyncAccessories
    ------------------------------------
    Sorgente ACCESSORI in formato srvsql.dbtopruote.dbo.artico (ditta TOPRUOTE).
    Usata da dbo.SpNtsArticoUpsertAccessories.

    NOTE
    > ar_sotgru = 1600 + ProductSubTypeId. I 243 accessori con ProductSubTypeId
      NULL finiscono su 1601, coerentemente con le 423 righe gia' presenti in
      artico su quel sottogruppo.
    > Il sottotipo 69 (RUOTINO EMERGENZA) NON appartiene agli accessori: e' il
      sottotipo dei ricambi, gestito da ViewNtsSyncSpares. In dbo.Accessories
      non esiste alcuna riga con ProductSubTypeId = 69.
    > Gli accessori non hanno misure geometriche: nessuna colonna ar_cer* / ar_pn*.
    > Nessun filtro su PubblicationTypes.

    TEST:
        SELECT * FROM dbo.ViewNtsSyncAccessories WHERE ar_codart = 'ZMG0000026001';
*/
CREATE OR ALTER VIEW dbo.ViewNtsSyncAccessories
AS

SELECT
    -- chiave
     codditt              = CAST('TOPRUOTE' AS VARCHAR(12))
    ,ar_codart            = CAST(a.Id AS VARCHAR(50))

    -- descrizione (convenzione NTS: 40 + 40 caratteri)
    ,ar_descr             = CAST(LEFT(a.Descr, 40) AS VARCHAR(255))
    ,ar_desint            = CAST(SUBSTRING(a.Descr, 41, 40) AS VARCHAR(40))

    -- codici alternativi: NULL quando la sorgente non ha un valore reale
    ,ar_codalt            =
        CAST(CASE
            WHEN LTRIM(RTRIM(a.ManufacturerCode)) = ''  THEN NULL
            WHEN a.ManufacturerCode = a.Id              THEN NULL   -- placeholder, non un codice fornitore
            ELSE LTRIM(RTRIM(a.ManufacturerCode))
        END AS VARCHAR(50))
    ,ar_hhean             =
        CAST(CASE
            WHEN LTRIM(RTRIM(a.Ean)) = ''  THEN NULL
            WHEN a.Ean = a.Id              THEN NULL   -- placeholder, non un EAN
            ELSE LTRIM(RTRIM(a.Ean))
        END AS VARCHAR(50))

    -- classificazione
    ,ar_gruppo            = CAST(16 AS SMALLINT)
    ,ar_sotgru            = CAST(1600 + ISNULL(a.ProductSubTypeId, 1) AS SMALLINT)
    ,ar_claprov           = CAST(16 AS SMALLINT)
    ,ar_controp           = CAST(5372 AS SMALLINT)
    ,ar_controa           = CAST(5376 AS SMALLINT)
    ,ar_famprod           = CAST(a.BrandId AS VARCHAR(4))
    ,ar_codnomc           = CAST(CASE a.ProductSubTypeId
                                     WHEN 77 THEN '9026.20.20'   -- TPMS - VALVOLE / SENSORI
                                     WHEN 78 THEN '9026.20.20'   -- TPMS - ACCESSORI MONTAGGIO / DIAGNOSI
                                     WHEN 95 THEN '9026.20.20'   -- TPMS - VALVOLE RICAMBIO
                                     ELSE         '8708.70.99'
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
    -- Per gli accessori la scelta e' comunque neutra: in dbo.Accessories netto
    -- e lordo coincidono su tutte e 5.698 le righe.
    ,ar_pesonet           = CAST(p.peso AS DECIMAL(27,9))
    ,ar_pesolor           = CAST(p.peso AS DECIMAL(27,9))

FROM dbo.Accessories a
LEFT JOIN dbo.ProductSubTypes pst
    ON  pst.ProductTypeId = a.ProductTypeId
    AND pst.Id            = a.ProductSubTypeId

-- fallback peso per sottotipo (da ViewNtsSyncProducts)
CROSS APPLY (
    SELECT pesoDefault =
        CASE a.ProductSubTypeId
            WHEN  2 THEN 1.5    -- DISTANZIALI
            WHEN  8 THEN 0.8    -- CAMERE D'ARIA
            WHEN 16 THEN 6      -- CATENE DA NEVE AUTOVETTURA
            WHEN 17 THEN 0.8    -- RUOTINO - BULLONERIA
            WHEN 18 THEN 0.1    -- RUOTINO - ANELLI
            WHEN 19 THEN 0.5    -- RUOTINO - SACCA
            WHEN 20 THEN 0.8    -- RUOTINO - CHIAVE
            WHEN 21 THEN 7      -- RUOTINO - RUOTE LEGA
            WHEN 22 THEN 5      -- RUOTINO - RUOTA FERRO
            WHEN 23 THEN 2.5    -- RUOTINO - CRIC
            WHEN 32 THEN 10     -- CATENE DA NEVE 4x4 / MINIBUS
            WHEN 64 THEN 20     -- CATENE DA NEVE AUTOCARRO
            WHEN 65 THEN 1      -- BULLONERIA STANDARD
            WHEN 66 THEN 2      -- BULLONERIA DISTANZIALI
            WHEN 67 THEN 0.1    -- ANELLI CENTRAGGIO
            WHEN 68 THEN 0.8    -- BULLONERIA ANTIFURTO
            WHEN 69 THEN 15     -- RUOTINO EMERGENZA
            WHEN 70 THEN 1      -- BULLONERIA ORIG.
            WHEN 71 THEN 1.5    -- KIT FORATURA
            WHEN 72 THEN 1.5    -- COPPONE DOTZ
            WHEN 73 THEN 0.5    -- ANELLO PROTEZIONE CERCHI
            WHEN 74 THEN 1      -- ACCESSORI MONTAGGIO PNEUMATICI
            WHEN 75 THEN 1      -- KIT MONTAGGIO CERCHIO
            WHEN 76 THEN 0.8    -- ABBIGLIAMENTO DA LAVORO
            WHEN 77 THEN 0.2    -- TPMS - VALVOLE / SENSORI
            WHEN 78 THEN 1      -- TPMS - ACCESSORI MONTAGGIO / DIAGNOSI
            WHEN 79 THEN 2.5    -- COPRIRUOTA - SET BORCHIE
            WHEN 80 THEN 1      -- BULLONERIA
            WHEN 81 THEN 1.5    -- KIT PULIZIA
            WHEN 82 THEN 0.2    -- COPRI BULLONI
            WHEN 83 THEN 0.5    -- LAMPADE / FARI
            WHEN 84 THEN 0.4    -- SPAZZOLE TERGI
            WHEN 85 THEN 0.3    -- TPMS - RICAMBI / MATERIALE DI CONSUMO
            WHEN 86 THEN 1      -- ACCESSORI MONTAGGIO CERCHI
            WHEN 87 THEN 8      -- DISCHI FRENO
            WHEN 88 THEN 2      -- PASTIGLIE FRENO
            WHEN 89 THEN 0.2    -- CUP - LENTI
            WHEN 90 THEN 15     -- ESPOSITORI CERCHI IN LEGA
            WHEN 91 THEN 6      -- PARAURTI - ALETTONI - KIT ESTETICI
            WHEN 92 THEN 0.5    -- FILTRI
            WHEN 93 THEN 10     -- SCARICHI SPORTIVI
            WHEN 94 THEN 1      -- VARIE
            WHEN 95 THEN 0.1    -- TPMS - VALVOLE RICAMBIO
            WHEN 96 THEN 10     -- RUOTINO - KIT BASE
            WHEN 97 THEN 1      -- RUOTINO - ACCESSORI
            ELSE 0.5
        END
) d
CROSS APPLY (
    SELECT peso = CASE WHEN a.NetWeightKg > 0 THEN a.NetWeightKg ELSE d.pesoDefault END
) p

WHERE a.ProductTypeId = 16;
