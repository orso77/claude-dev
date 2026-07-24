# Import stocks cerchi — mapping fornitori e schema DB

Sessione 2026-06-04. Riferimento: vecchio `MontiEcomm.Giacenze.2.0` (Cerchi_Fornitori), nuovo `Wheels.Net.ImportStocks`.

## Schema tabelle WheelsNet

### dbo.DistributorProductStocks (destinazione, era vuota)
PK composta: (`ProductId`, `Ean`, `DistributorId`, `ManufacturerCode`).

| Colonna | Tipo | Note |
|---|---|---|
| ProductId | nchar(25) NOT NULL | = `Wheels.Id` (es. `CL00000508167`) ricavato via match |
| Ean | varchar(50) NOT NULL | ean dal file (vuoto se assente) |
| DistributorId | int NOT NULL | anagrafica fornitore (NON presente nel DB → fornita a mano) |
| ManufacturerCode | varchar(50) NOT NULL | codice articolo dal file fornitore |
| AvailableStock | decimal NOT NULL | quantità |
| BuyingPrice | decimal NOT NULL | prezzo d'acquisto (0 se il fornitore non lo manda) |
| Timestamp | datetime NULL | `DateTime.Now` dell'import |

### Legame con dbo.Wheels
- `Wheels.Id` varchar(50) = ProductId interno (`CL...`/`CF...`).
- `Wheels.ManufacturerCode` varchar(50) = codice produttore **puro** (no prefisso) → match per la maggior parte dei fornitori.
- `Wheels.Ean` varchar(50) → match per i fornitori che mandano solo l'EAN (Oz).
- ~69k wheels, ~68k ManufacturerCode distinti.

### dbo.WheelPrices (update a fine import)
PK `ProductId`. Campi toccati: `TopBuyingPriceOut`, `TopBuyingPriceNts`. (Solo UPDATE su righe esistenti, niente insert.)

### vista dbo.NtsProductBuyingPrices
Colonne: `ProductId`, `TopAvgBuyingPrice`, `TopLastBuyingPrice`, `TopStock`, `Rev*`, `Mnt*`, `Aut*`.
Per `TopBuyingPriceNts` si usa **`TopLastBuyingPrice`** (deciso dall'utente).

## Mapping per fornitore (indici 0-based, dal vecchio codice)

| key | parser | matchBy | delim | header | code | ean | qty | price | download | note |
|---|---|---|---|---|---|---|---|---|---|---|
| alcar | alcar | code | ; | 3 | 0 | 3 | 1+2 | 4 | FTP ftp.alcar-wheels.com (3 file CL/CF/AC merge) | qty = local+external |
| etabeta | csv | code | ; | 1 | 1 | - | 13 | 16 | HTTP etabetawheels.it | |
| arcasting | xlsx | code | ; | 1 | 0 | - | 7 | - | locale xlsx→csv | celle fra `"` |
| gmp | csv | code | , | 1 | 0 | 1 | 2 | - | API api.gmpitalia.com (OAuth2) | |
| antera | csv | code | , | 1 | 0 | 1 | 2 | - | API api.antera.com (OAuth2) | |
| mak-stock | csv | code | ; | 1 | 0 | - | 1 | - | locale | solo stock (no Mak full) |
| momo | csv | code | ; | 0 | 0 | - | 1 | - | FTP mail.momo.it | campi de-quotati |
| fondmetal | csv | code | ; | 1 | 1 | - | 37 | - | locale | tracciato 2025-01 |
| oz | xlsx | **ean** | ; | 1 | - | 20 | 14 | - | locale xlsx→csv | qty con `>` da togliere; no codice |
| rvs | csv | code | ; | 1 | 10 | - | 9 | - | locale | prefix vecchio AVS_ |
| uniwheels-anz | csv | code | ; | 1 | 0 | 1 | 12 | - | locale | UTP_*.csv |
| uniwheels-ril | csv | code | \| | 1 | 0 | 1 | 4 | - | locale | UWLM_*.csv, delim pipe |
| ew | csv | code | ; | 1 | 1 | - | 23 | - | locale | |
| bracchi | csv | code | ; | 1 | 0 | - | 1 | 2 | locale | CerchiFerro |
| emiliaruote | csv | code | ; | 1 | 0 | - | 1 | 2 | locale | |
| wsp | wsp | code | ; | 0 | 0 | - | 1 | - | locale | qty nel formato "AVAILABLE (n)" |
| brock | csv | code | ; | 1 | 1 | - | 31 | - | locale | prefix vecchio MIM_ |

Note:
- `uniwheels` = AnzioAnz (ANZ) + AnzioRil (RIL): **stesso DistributorId** → il DELETE va fatto una sola volta (gestito raggruppando per DistributorId).
- Filtro storico del vecchio import: si tiene la riga solo se **qty ≥ 4** (`minQty`, configurabile per fornitore).
- I prefissi vecchi (ALC_, EB_, OZ_, MIM_, ...) servivano per `COD_ART_FORNITORE_720`: nel nuovo schema **non si usano** (match su codice puro).
- Esclusi dai 16 richiesti: Mak (full), InterpneuCL, Oxigin, PswRuote/PswRuotini.

## Decisioni / assunzioni

- **ProductId non risolto** (nessun match su code/ean) → riga **scartata** + log conteggio.
- **TopBuyingPriceOut** = `MIN(BuyingPrice)` per ProductId, **solo dove prezzo > 0**. Ora in **UPSERT** (MERGE): se il ProductId non è in WheelPrices viene **inserito** con tutti i prezzi a 0 tranne TopBuyingPriceOut; l'INSERT è generato dallo schema (`GetColumns`). La maggior parte dei fornitori NON manda il prezzo (solo alcar/etabeta/bracchi).
- **disabled**: proprietà opzionale per fornitore in appsettings (`"disabled": true`) → esclude il flusso dall'import (default false).
- **Timestamp** = data del **file importato** (per riga): locali/xlsx/wsp → `LastWriteTime` del sorgente; alcar → data remota FTP di un file base (`GetModifiedTime`, fallback locale); http/api → momento del download.
- **TopBuyingPriceNts** = `NtsProductBuyingPrices.TopLastBuyingPrice`.
- **Dedup** righe sulla PK prima del bulk (ultima vince).
- **Safety**: rifiuto connessione a `192.168.100.52` senza flag `--prod`.

## DistributorId (dbo.Distributors)

Decisione finale (richiesta utente): il `DistributorId` è **fisso in `appsettings.json`** (niente lookup a runtime, niente `pref`/`key` nel config). L'identificativo del flusso per CLI/log è il `savedFileName` senza estensione (`SupplierConfig.Name`). Gli Id provengono dalla mappatura prefisso→Id fornita dall'utente (`dbo.Distributors`):

| flusso (Name) | prefisso storico | DistributorId | Descr |
|---|---|---|---|
| alcar | ALC_ | 251504767 | ALCAR ITALIA SRL |
| etabeta | EB_ | 251503407 | ETABETA S.p.A. |
| arcasting | ARC_ | 251510391 | ARCASTING |
| gmp | GMP_ | 251510772 | GMP |
| antera | ANT_ | 251510772 | GMP (Antera distribuito da GMP → stesso Id) |
| mak-stock | MAK_ | 251506274 | MAK s.p.a. |
| momo | MOM_ | 251510525 | MOMO SRL |
| fondmetal | FND_ | 251511186 | FONDMETAL SPA |
| oz | OZ_ | 251505680 | O.Z. SPA |
| rvs | AVS_ | 251510725 | AVS |
| uniwheels-anz | UNI_ | 251504231 | UNIVERGOMMA S.P.A. |
| uniwheels-ril | RIL_ | 251510994 | SUPERIOR |
| ew | EWW_ | 251511323 | ELITE |
| bracchi | GIA_ | 251510134 | DAL POZZO MARIO & C. SRL |
| wsp | WSP_ | 251506910 | ACACIA S.R.L. |
| brock | MIM_ | 251510151 | MIM TECNOMAGNESIO SRL |
| **emiliaruote** | ER_ | **0 (MANCANTE)** | ER_ non presente nel mapping fornito → flusso saltato |

Note:
- **gmp + antera** condividono `DistributorId = 251510772` → vengono raggruppati (un solo DELETE, bulk combinato).
- **emiliaruote** resta a `0` (skip con log) finché non viene fornito il suo DistributorId.
- I fornitori con `distributorId = 0` vengono **saltati con log**.

## Path file e ambienti

- Path reali dei file presi da `C:\!claude\!swap\wheels-net-bo\MontiEcomm.Giacenze.exe.config` → `C:\app\MontiEcomm.Giacenze\temp\...`.
- 3 nomi file differiscono dall'app.config del repo: fondmetal `FM_WheelsTechData_EUR.csv`, oz `StockTopruote.xlsx`, uniwheels-ril `UWLM_best_ATS_RIAL.csv`.
- `appsettings.json` = produzione (`192.168.100.52`), `appsettings.Development.json` = locale (`Server=.`). La sezione `Suppliers` (con i path) è replicata in entrambi.

## Note operative (sessione 2026-06-04, primo run completo)

- **EPPlus 8** richiede la nuova API licenza: `ExcelPackage.License.SetNonCommercialOrganization("TopRuote")` (la vecchia `ExcelPackage.LicenseContext` lancia `LicenseNotSetException`). Riguarda i parser xlsx (arcasting, oz). ⚠️ Uso commerciale → licenza a pagamento; valutare OpenXML/ClosedXML gratuiti.
- **Log su file**: ogni run scrive `!Log.log` nella cartella `import\<timestamp>\` (il `!` lo tiene in cima). La cartella viene creata a inizio run.
- **DistributorProductStocks**: colonna codice fornitore = **`ManufacturerCode`** (PK `ProductId, Ean, DistributorId, ManufacturerCode`).
- **Match Alcar CF (cerchi ferro)**: alcuni record (es. `9816`) non matchano per codice ma hanno EAN valido in Wheels → valutare fallback match per EAN quando il codice non si abbina.
- **uniwheels-anz**: file `\\192.168.100.5\e$\ftp\uniwheels\UTP_9001430.csv` non presente al primo run (path/nome da verificare).
- Esiti primo run (locale): ~17k righe importate; `WheelPrices.TopBuyingPriceOut` 4323, `TopBuyingPriceNts` 11814.

## Punti aperti / rischi

- **DistributorId mancante** per emiliaruote (ER_ non nel mapping): da fornire, altrimenti il flusso resta saltato.
- **Credenziali FTP/API** in chiaro in `appsettings.json` (come nel vecchio codice). Valutare secret store.
- **EPPlus 8.x**: licenza Polyform NonCommercial (impostata `NonCommercial` come nel vecchio progetto). Uso commerciale potrebbe richiedere **licenza a pagamento** → da chiarire con l'utente.
- **Indici colonna** dei tracciati fornitore cambiano spesso nel tempo: vanno verificati sui file reali correnti.
