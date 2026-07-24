# Progetto import-stocks (Wheels.Net.ImportStocks)

Riscrittura moderna e semplificata dell'importazione **giacenze/stock dei cerchi** dai fornitori,
in sostituzione del vecchio `MontiEcomm.Giacenze.2.0` (.NET Framework 4.8).

## Path principali

- **Progetto nuovo**: `C:\src\s2engineering\wheels-net\wheels-net\Wheels.Net.ImportStocks` (.NET 10, console)
- **Vecchio programma (riferimento mapping)**: `C:\src\topruote\Wheels\MontiEcomm.Giacenze.2.0`
- **DB**: `WheelsNet` (produzione `Server=192.168.100.52` — i test di scrittura SOLO su locale `.\`)

## Cosa fa (semplice e lineare, niente gerarchia del vecchio programma)

1. Per ogni fornitore cerchi selezionato: scarica (FTP/HTTP/API) o copia il file in una cartella di run
   `import\yyyyMMddHHmmss\` (import sempre da copie locali → niente lock sugli originali).
2. Parsa le righe (codice/ean/qta/prezzo) secondo gli indici di colonna configurati in `appsettings.json`.
3. Ricava `ProductId` da `Wheels` per match su `ManufacturerCode` (default) o `Ean` (fornitori senza codice, es. Oz).
4. `DELETE` per `DistributorId` (brucia il vecchio del distributore) + `SqlBulkCopy` in `dbo.DistributorProductStocks`.
5. A fine import aggiorna `WheelPrices`:
   - `TopBuyingPriceOut` = MIN(`BuyingPrice`) per `ProductId` dallo stock importato, solo dove prezzo > 0 (non azzera).
   - `TopBuyingPriceNts` = `TopLastBuyingPrice` dalla vista `NtsProductBuyingPrices`, per `ProductId`.

## Uso

```
ImportStocks [fornitore1 fornitore2 ...] | all  [--prod]
```
- nessun argomento o `all` → tutti i fornitori configurati
- `uniwheels` → include `uniwheels-anz` + `uniwheels-ril`
- `--prod` → consente di puntare alla produzione (di default rifiutata se la cnx contiene `192.168.100.52`)

## Stato / TODO

- [x] Scaffolding completo, build OK (0 warning / 0 errori).
- [ ] **DistributorId reali**: in `appsettings.json` sono a `0` (placeholder). Vanno popolati prima dell'esecuzione.
- [ ] Test end-to-end su DB **locale** con file fornitori reali.
- [ ] Verificare gli **indici di colonna** dei file fornitori (i tracciati cambiano spesso; presi dal vecchio codice al 2026-06).

## Analisi

- [Mapping fornitori e schema DB](mapping-analysis.md) — indici colonna per fornitore, download, schema tabelle, decisioni.
