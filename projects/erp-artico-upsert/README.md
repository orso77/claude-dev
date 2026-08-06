# Progetto erp-artico-upsert — invio articoli WheelsNet → ERP NTS

Stored procedure in `WheelsNet` che fanno **upsert** dell'anagrafica articoli in
`srvsql.DBTOPRUOTE.dbo.artico` (ERP NTS, ditta `TOPRUOTE`), **una per tipologia di prodotto**,
ciascuna con parametro unico `@id VARCHAR(50)` = `Id` della relativa tabella sorgente.

Sostituisce il vecchio `srvsql.DBTOPRUOTE.dbo._UpsertArticoCodart`, che legge dal sistema dismesso
(`[192.168.100.18].[gommeauto].[dbo].[_ToNts_artico_tires]`) e gestisce **solo i pneumatici**.

## Stato

| | |
|---|---|
| Script SQL | ✅ scritti in `sql/`, sintassi e riferimenti validati contro produzione |
| Deploy in produzione | ⛔ **non eseguito** — richiede autorizzazione esplicita |
| Primo upsert reale | ⛔ non eseguito |

Nessuna scrittura è mai stata fatta sull'ERP: tutta l'analisi è avvenuta in sola lettura.

## Documenti

- [`artico-field-mapping.md`](artico-field-mapping.md) — mappatura completa campo per campo e tutte
  le evidenze raccolte in produzione (tipi, costanti, conteggi, copertura, trigger).
- [`decisioni.md`](decisioni.md) — decisioni prese, con il razionale e i numeri a supporto.

## Oggetti

Tutti in `WheelsNet`, tutti `CREATE OR ALTER` (ri-deployabili).

| # | Oggetto | Sorgente | `ar_gruppo` / `ar_sotgru` |
|---|---|---|---|
| 01 | `dbo.ViewNtsSyncTyres` | `dbo.Tyres` | 2 / 201 |
| 02 | `dbo.ViewNtsSyncWheels` | `dbo.Wheels` | 4 / 401 (lega) · 8 / 801 (ferro) |
| 03 | `dbo.ViewNtsSyncSpares` | `dbo.Spares` | 16 / 1669 |
| 04 | `dbo.ViewNtsSyncAccessories` | `dbo.Accessories` | 16 / `1600 + ProductSubTypeId` |
| 05 | `dbo.SpNtsArticoUpsertTyres` | `ViewNtsSyncTyres` | |
| 06 | `dbo.SpNtsArticoUpsertWheels` | `ViewNtsSyncWheels` | |
| 07 | `dbo.SpNtsArticoUpsertSpares` | `ViewNtsSyncSpares` | |
| 08 | `dbo.SpNtsArticoUpsertAccessories` | `ViewNtsSyncAccessories` | |

Il mapping sta nelle **view**, non nelle stored: le stored contengono solo `UPDATE … FROM` +
`INSERT … WHERE NOT EXISTS` e le date di esecuzione. Così il mapping è riusabile per il
caricamento massivo iniziale con un `INSERT … SELECT` dalla view.

## Uso

```sql
-- prova a secco: non scrive nulla, mostra affiancati il calcolato e l'attuale in artico
EXEC dbo.SpNtsArticoUpsertWheels 'CL00000457062', @debug = 1;

-- upsert reale
EXEC dbo.SpNtsArticoUpsertWheels 'CL00000457062';
```

Se l'`@id` non esiste nella tabella sorgente: nessuna riga toccata, nessun errore.
Non c'è alcun filtro su `PubblicationTypes`.

## Attenzione ai nomi

`dbo.ViewNtsTyres` e `dbo.ViewNtsWheels` **esistono già** in `WheelsNet` ma leggono **da `artico`**
(viste di ispezione lato ERP, semantica opposta). Le nuove viste usano il prefisso `ViewNtsSync*`,
coerente con `ViewNtsSyncProducts` che è la direzione WheelsNet → artico.

`ViewNtsSyncProducts` resta dov'è, **non modificata e non usata a runtime**: è servita solo come
riferimento per i `CASE` di fallback peso e i codici doganali. Contiene diversi errori di mappatura,
elencati in [`artico-field-mapping.md`](artico-field-mapping.md).

## Prerequisiti prima del primo upsert reale

1. Eseguire `WheelsNet.dbo.SpNtsBrandsUpsert`: 9 brand pubblicati non esistono in `tabcfam`
   (ATR, CBF, EVT, EZS, JP, KR, ORF, ORSS, ZZZ) e finirebbero in `ar_famprod` senza anagrafica.
2. Verificare che il sottogruppo `1669` sia censito in `tabsgme` per la ditta `TOPRUOTE`
   (di fatto lo è: ci sono già 5.618 articoli).

## Sequenza di deploy proposta

1. Deploy delle sole **4 view** (impatto nullo: nessuna scrittura, nessun oggetto esistente toccato).
2. Validazione a secco con `@debug = 1` su un articolo per tipologia:
   `ZZ00000849390`, `CL00000457062`, `ZAC00000ORP0S`, `RUNUVKRL0001A`, `ZMG0000026001`.
3. Deploy delle **4 stored**.
4. Primo upsert reale su un articolo **già presente** in `artico` (percorso UPDATE), con `SELECT`
   prima/dopo e controllo che i trigger abbiano accodato la riga attesa in `SyncQueue`.
5. Secondo test su un articolo **assente** (percorso INSERT), scelto tra gli 80.211 pneumatici mancanti.
6. Solo a valle: valutare il caricamento massivo, a blocchi.
