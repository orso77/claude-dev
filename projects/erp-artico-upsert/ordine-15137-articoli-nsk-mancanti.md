# Ordine R-2026-Y-15137 — import connettore fallito: articoli `SNSK*` assenti in `artico`

Data analisi: 06/08/2026. File esaminati: `C:\!!claude-temp\ORDINI-CONNETTORE\T1725TES.TXT`,
`T1725MOV.TXT` (sola lettura, nessuna query su produzione).

## Sintomo

```
[WARN ] BUS ERROR: Codice Articolo inserito non presente in archivio
[WARN ] BUS ERROR: Il codice articolo è un campo obbligatorio... (per il momento verrà impostato l'articolo 'D')
[ERROR] Errore in salvataggio riga: Doc. R 2026 Y 15137 riga: 100
[ERROR] Errore creazione documento R-2026-Y-15137
System.NullReferenceException in VisionOne.Core.Logging.Logger.Error(String message, Exception ex)
```

Solo l'ordine 15137 fallisce; tutti gli altri del batch passano.

## Causa

L'ordine 15137 ha 19 righe: 18 ricambi con codice `SNSK*` + `SP030` (spese spedizione).
I codici `SNSK*` **non esistono in `srvsql.DBTOPRUOTE.dbo.artico`**. La riga 100
(`SNSK000BAG006`) è la prima e fa fallire il salvataggio dell'intero documento.

I 18 codici sono un mirror 1:1 dei ricambi `SP0*` (brand *356 COMPONENTS*, già censiti in ERP)
per il brand **NSK**:

| Nuovo (assente) | Equivalente esistente |
|---|---|
| `SNSK000BAG001..007` | `SP00000BAG001..007` |
| `SNSK00CRIC001/002/003/005` | `SP0000CRIC001/002/005` |
| `SNSKCHIAVE001..004` | `SP00CHIAVE001..004` |
| `SNSK000GLOVE1` | `SP00000GLOVE1` |
| `SNSK000GILET1`, `SNSKCOMPRKIT1` | nessuno |

Nel batch i codici `SNSK*` compaiono **solo** in questo ordine: è il primo ordine di ricambi NSK.

Conferma dalla lunghezza campo: i codici sono 13 caratteri come tutti gli altri
(`KIT0000BSC133`, `SP00CHIAVE001`), quindi non è un problema di troncamento del tracciato.

## Collegamento col progetto

È esattamente il buco che `SpNtsArticoUpsertSpares` deve chiudere: l'anagrafica ricambi nasce in
WheelsNet (`dbo.Spares`) e oggi **non viene propagata** in `artico` (il vecchio
`_UpsertArticoCodart` gestisce solo i pneumatici). Finché l'upsert non è deployato, ogni nuovo
ricambio/brand fa fallire l'import dell'ordine che lo contiene.

## Nota secondaria — `NullReferenceException` fuorviante

L'eccezione **non è la causa**: è un bug del bus ERP. Dopo l'errore di salvataggio,
`DocumentManager.AggiornaCreaDoc` chiama `Logger.Error(message, ex)` con un argomento null e il
logger va in NRE, che risale fino a `OrdiniTopRuote.SyncAllOne` (`Ordini.cs:384`). Effetto: il
messaggio d'errore vero viene perso e la eccezione riportata sembra un crash del connettore.
Codice di terze parti (`VOne.OneConn.Plugs.TopRuote.dll`), non modificabile da noi.

## Come rimediare

1. Censire i 18 articoli `SNSK*` in `artico` (ditta `TOPRUOTE`), copiando i corrispondenti `SP0*`
   per gruppo/sottogruppo (16 / 1669), IVA, unità di misura, conto ricavo (`5372`).
2. Rilanciare l'import dell'ordine 15137.
3. A regime: deployare `SpNtsArticoUpsertSpares` e agganciarla al flusso, così i nuovi ricambi
   arrivano in ERP prima degli ordini che li usano.

## Da verificare (richiede lettura su produzione, non autorizzata)

- `SELECT ar_codart FROM srvsql.DBTOPRUOTE.dbo.artico WHERE ar_codart LIKE 'SNSK%'` → atteso: 0 righe.
- Presenza dei 18 codici in `WheelsNet.dbo.Spares` e loro resa in `ViewNtsSyncSpares`.
