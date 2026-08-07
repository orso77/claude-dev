# Aggiunta campi da `WheelsNet.dbo.Spares` alle 3 SP stock 356 (2026-08-07)

Richiesta: aggiungere **in coda** alle SP `SpStock_356NuvolariV001`, `SpStock_356V001`,
`SpStock_356V008_Nsk` (produzione `192.168.100.52` / `WheelSystemsExport`) i campi
`Img1..Img5, Width, Diameter, Holes, Pcd1, MadeIn, NetWeightKg, GrossWeightKg, MaxLoad,
Tyre, BoxSize, Material, TrunkSize`, **senza duplicare i campi già presenti**, seguendo
criteri/funzioni dei campi esistenti. Backup preventivo con suffisso `_202608071330`.

## Backup creati (produzione)

Script idempotente: `sql/backup_202608071330.sql` (copia la definizione corrente con
`OBJECT_DEFINITION` + `REPLACE` del nome, come da convenzione già in uso nel DB —
es. `SpStock_RevorimV001_202604201100`).

| Backup | Esito |
|---|---|
| `dbo.SpStock_356NuvolariV001_202608071330` | CREATED |
| `dbo.SpStock_356V001_202608071330` | CREATED |
| `dbo.SpStock_356V008_Nsk_202608071330` | CREATED |

## Sorgente dei campi

Tutti e 17 i campi richiesti esistono con lo stesso nome in `WheelsNet.dbo.Spares`,
già joinata nelle 3 SP come alias `spr` (LEFT JOIN su `spr.Id = p.Id`). Nessun nuovo
join introdotto.

## Criteri di formattazione adottati (e perché)

Le SP stock esistenti usano solo `FnStringCleaner` (stringhe) e `FnDecimalFormat2`
(decimali, formato `0,00` con lo zero mantenuto). Per i campi dimensionali esiste però
una convenzione consolidata nelle SP stock sorelle dello stesso DB
(`SpStock_RevorimV004`, `SpStock_TopAllWheelsV001`, `SpStock_MilleMigliaV001`):

| Campo | Funzione | Precedente seguito |
|---|---|---|
| `Img1..Img5` | `CASE WHEN spr.ImgN > '' THEN WheelsNet.dbo.FnUrlImg('356','large/'+spr.ImgN) ELSE '' END` | `SpFitmentSpares_356V009_BaseEbay` (colonne `Img1..Img5` identiche) |
| `Width`, `Diameter`, `Pcd1`, `MaxLoad` | `dbo.FnDecimalFormat(x, '0.#', ',')` | `SpStock_RevorimV004` / `SpStock_TopAllWheelsV001` |
| `Holes` | `dbo.FnDecimalFormat(x, '0', ',')` | idem (conteggio intero: `FnDecimalFormat2` darebbe `4,00`) |
| `MadeIn`, `Tyre`, `BoxSize`, `Material`, `TrunkSize` | `dbo.FnStringCleaner(x)` | `SpFitmentSpares_356V008_Nsk`, campi stringa già presenti |
| `NetWeightKg`, `GrossWeightKg` | `dbo.FnDecimalFormat2(x)` | `SpStock_356V001` (già presenti lì) |

Note:
- `FnDecimalFormat` restituisce **stringa vuota** quando il valore è 0; `FnDecimalFormat2`
  restituisce `0,00`. Scelta voluta: per i campi "specifica tecnica" un valore non
  valorizzato esce vuoto invece che come uno zero apparentemente reale.
- `MaxLoad` è stato accorpato ai campi specifica (non ai pesi) proprio per questo motivo:
  in `Spares` è **sempre 0** su tutte le 3163 righe, quindi con `FnDecimalFormat2`
  avrebbe stampato `0,00` su ogni riga.
- `FnUrlImg` fa `lower()` del risultato: gli URL escono minuscoli (coerente con gli altri export).
- Dominio immagini: `'356'` → `https://images.356automotive.com/` per **tutte e 3** le SP,
  NSK inclusa, coerentemente con la sorella `SpFitmentSpares_356V008_Nsk` (che usa `'356'`
  anche per i prodotti NSK). Verificato via HTTP 200 che le immagini NSK sono servite sia da
  `images.356automotive.com` sia da `images.nostopkit.com`.

## Campi NON aggiunti perché già presenti

Solo in `SpStock_356V001` (le altre due non avevano nessuno dei 17 campi):

| Campo richiesto | Già presente come | Sorgente |
|---|---|---|
| `NetWeightKg` | `NetWeightKg` | `spr.NetWeightKg` |
| `GrossWeightKg` | `GrossWeightKg` | `spr.GrossWeightKg` |
| `BoxSize` | `BoxSizeCm` | `spr.BoxSize` |
| `TrunkSize` | `TrunkSizeCm` | `spr.TrunkSize` |

`BoxSizeCm`/`TrunkSizeCm` hanno nome diverso ma **stessa identica sorgente e stessa
funzione** dei campi richiesti: aggiungerli avrebbe prodotto due colonne con lo stesso
contenuto. Se il consumatore a valle vuole comunque i nomi `BoxSize`/`TrunkSize`,
la scelta corretta è **rinominare** le esistenti, non duplicarle.

## Tracciati risultanti

| SP | Colonne prima | Aggiunte | Colonne dopo |
|---|---|---|---|
| `SpStock_356V001` | 17 | 13 | **30** |
| `SpStock_356NuvolariV001` | 13 | 17 | **30** |
| `SpStock_356V008_Nsk` | 13 | 17 | **30** |

⚠️ **Impatto a valle**: i CSV generati da `03-356automotive-stock.bat` cambiano tracciato
(colonne in più in coda). Gli importer dei clienti vanno avvisati/verificati.

⚠️ `SpStock_356NuvolariV001` nasceva esplicitamente come variante **senza** dimensioni/pesi
(13 colonne). Con questa modifica quei dati tornano nel file di tagliabue (53000577).

## Verifiche eseguite (produzione, sola lettura)

| SP | Cliente | Righe | Note |
|---|---|---|---|
| `SpStock_356V001` | 53000522 (4s) | **793** | invariato rispetto al valore storico documentato |
| `SpStock_356NuvolariV001` | 53000577 (tagliabue) | **793** | invariato |
| `SpStock_356V008_Nsk` | 53001952 (NO STOP KIT) | **1115** | — |

Esempio riga (`RU000KOE0001S`, 4s): `…;16,00;16,50;https://images.356automotive.com/large/356_kitoe_ruotino_new_ferro_cric_chiavestd.jpg;;;;;;15;4;100;;;125/70R15;FERRO`

Osservazioni sui dati (`Spares`, 3163 righe):
- `Width` = 0 su tutte le righe → esce sempre vuoto.
- `MaxLoad` = 0 su tutte le righe → esce sempre vuoto.
- `MadeIn` = '' su tutte le righe → esce sempre vuoto.
- `Img2..Img5` valorizzate su 1106/3163 righe (in pratica solo i prodotti NSK; per i brand
  348/349/380 è popolata la sola `Img1`).
- `Diameter` ha un minimo di `-1` (valore sporco a monte, non gestito qui).

## File

- `sql/backup_202608071330.sql` (nuovo)
- `sql/SpStock_356V001.sql` (aggiornato)
- `sql/SpStock_356NuvolariV001.sql` (aggiornato)
- `sql/SpStock_356V008_Nsk.sql` (nuovo in repo — la SP esisteva solo in produzione)
