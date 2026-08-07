# `SpStock_356V008_Nsk`: gli accessori NSK non escono (es. `SNSK000BAG001`)

Analisi 2026-08-07 su produzione `192.168.100.52` (sola lettura).

## Sintomo

`SNSK000BAG001` (SPAREPART NSK BAG 1) non compare nel file di stock NSK, mentre sul b2b
Automotive lo stesso articolo è pubblicato (`PubblicationTypes` include il bit 256) e ha
un prezzo.

## Root cause

Non è un problema di "prezzo 0": **la riga non esiste proprio** nel result set che la SP
usa come filtro.

`SpStock_356V008_Nsk` fa `INNER JOIN #pp`, dove `#pp` viene popolata da
`WheelsNet.dbo.SpAutPriceSpares`. Quella procedura legge da:

```sql
from Spares wh
left join SparePrices pp on pp.ProductId = wh.Id
```

`WheelsNet` tiene **ruotini e accessori in due anagrafiche separate**:

| Anagrafica | Prezzi | ProductTypeId | Procedura prezzi |
|---|---|---|---|
| `WheelsNet.dbo.Spares` | `SparePrices` | 22 | `SpAutPriceSpares` |
| `WheelsNet.dbo.Accessories` | `AccessoryPrices` | 16 | `SpAutPriceAccessories` |

`SNSK000BAG001` **non è in `Spares`** (né in `SparePrices`): è in `Accessories`
(`ProductTypeId=16`, `ProductSubTypeId=19`, `PubblicationTypes=19390` → include il bit 256).
Quindi `SpAutPriceSpares` non può restituirlo in nessun caso, nemmeno con
`@includeZeroNetPrice=1`, e l'`INNER JOIN` lo elimina dall'export.

Il b2b Automotive lo vede perché per gli accessori chiama l'altra procedura,
`SpAutPriceAccessories`, che ha **tracciato identico** (le stesse 16 colonne) e per il
cliente 53001952 restituisce:

```
ProductId     ProductTypeId BrandId ListPrice NetPrice AvailStock OnArriveStock MissingPrice
SNSK000BAG001 16            NSK     18.0000   8.1000   624.00     2000.00       0
```

## Perimetro: 18 articoli NSK coinvolti

NSK ha 1133 prodotti in `WheelSystemsAutomotive.dbo.Products` ma solo 1115 in
`WheelsNet.dbo.Spares`. I 18 mancanti sono tutti accessori:

`SNSK000BAG001..007` (sacche), `SNSK000GILET1`, `SNSK000GLOVE1`, `SNSK00CRIC001/002/003/005`
(cric), `SNSKCHIAVE001..004` (chiavi), `SNSKCOMPRKIT1` (compressore).

Tutti e 18 escono da `SpAutPriceAccessories`.

Le altre due SP (`SpStock_356V001`, `SpStock_356NuvolariV001`) hanno lo stesso limite
strutturale, ma il loro `WHERE p.BrandId IN (348,349,380)` non intercetta gli accessori
356 (brand `356C`), quindi il sintomo lì non si vede.

## Fix applicato in produzione (2026-08-07 18:0x)

Backup preventivo della versione corrente: `dbo.SpStock_356V008_Nsk_202608071805`
(script `sql/backup_202608071805.sql`). Il backup `_202608071330` resta la versione
precedente all'aggiunta dei campi `Spares`.

Modifiche a `SpStock_356V008_Nsk`:
1. seconda `INSERT INTO #pp EXEC WheelsNet.dbo.SpAutPriceAccessories` (stesso tracciato
   a 16 colonne, insiemi disgiunti da `Spares` → nessun duplicato);
2. `LEFT JOIN WheelsNet.dbo.Accessories acc` e `COALESCE(spr.X, acc.X)` su
   `ProductDescr`, `Img1..Img5`, `NetWeightKg`, `GrossWeightKg`;
3. i campi cerchio restano su `spr` e quindi vuoti sulle righe accessorio.

Verifica (cliente 53001952): **1133 righe** (1115 ruotini + 18 accessori), 30 colonne,
riga ruotino di controllo invariata. Esempio riga accessorio:

```
SNSK000BAG001;8058627820114;0,00;40,00;EUR;18,00;8,10;2000,00;SPAREPART BAG 1;PFUGT02;1,80;NSK;
SPAREPART NSK BAG 1 - MISURA 58X14;https://images.356automotive.com/large/sacca_ruota_watermark.jpg;
https://images.356automotive.com/large/bagagliaio_watermark.jpg;;;;;;;;;0,50;0,50;;;;;
```

### ⚠️ Punto aperto: PFU sugli accessori

Il join del PFU è **incondizionato** (`LEFT JOIN NtsProducts nts ON nts.Id = 'PFUGT02'`,
nessuna correlazione col prodotto), quindi ogni riga esce con `PfuId=PFUGT02` e
`PfuEuroNoVat=1,80`. Finché nell'export c'erano solo kit ruotino era corretto; ora lo
stesso contributo PFU finisce anche su sacche, guanti, gilet, chiavi e compressore.
Da decidere se azzerarlo sulle righe accessorio (es. `CASE WHEN acc.Id IS NULL THEN ... ELSE '' END`).

## Fix proposto (poi applicato — vedi sopra)

Aggiungere una seconda `INSERT` nella stessa `#pp` — il tracciato è identico, quindi non
serve altro:

```sql
INSERT INTO #pp
EXEC WheelsNet.dbo.SpAutPriceAccessories
     @contactId           = @customerId
    ,@productId           = @productId
    ,@includeZeroNetPrice = 0;
```

**Attenzione ai campi descrittivi**: la SP fa `LEFT JOIN WheelsNet.dbo.Spares spr`, che per
gli accessori non trova nulla → `ProductDescr`, `Img*`, dimensioni e pesi uscirebbero vuoti.
Serve un fallback su `WheelsNet.dbo.Accessories`, che però ha solo un sottoinsieme di campi:

| Campo export | `Accessories` |
|---|---|
| `ProductDescr`, `Img1..Img5`, `NetWeightKg`, `GrossWeightKg` | presenti |
| `Width`, `Diameter`, `Holes`, `Pcd1`, `MadeIn`, `MaxLoad`, `Tyre`, `BoxSize`, `Material`, `TrunkSize` | **assenti** (sono specifiche del cerchio: per una sacca o un cric non hanno senso) |

Quindi: `LEFT JOIN WheelsNet.dbo.Accessories acc` + `COALESCE(spr.X, acc.X)` sui campi
comuni, e i campi wheel-only restano vuoti sulle righe accessorio.

Da decidere con l'utente prima di applicare: se gli accessori vadano davvero nel file di
stock NSK o se il consumatore a valle si aspetta solo i kit ruotino.
