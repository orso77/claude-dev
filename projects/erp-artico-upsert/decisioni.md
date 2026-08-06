# Decisioni di progetto — erp-artico-upsert

Decisioni prese il **2026-08-06**, con il razionale e i numeri che le hanno determinate.

## 1. Il mapping sta in 4 view, non nelle stored né in `ViewNtsSyncProducts`

**Decisione**: quattro view dedicate `ViewNtsSync{Tyres,Wheels,Spares,Accessories}`, con le stored
ridotte a `UPDATE … FROM` + `INSERT … WHERE NOT EXISTS` e al calcolo delle date.

**Non** per performance: misurata, `ViewNtsSyncProducts` filtrata per `ar_codart` costa **0 ms**,
perché il predicato viene spinto dentro tutti e 4 i rami della union. Le ragioni vere:

- è un **superset a colonne fisse**: i pneumatici trascinano 20 colonne `ar_cer*` a NULL e i cerchi
  tutte le `ar_pn*`; aggiungere un campo a una tipologia obbliga a toccare 4 rami;
- ha `ar_datins = GETDATE()` cablato dentro, valore che deve comparire solo in INSERT;
- filtra `PubblicationTypes > 0`, in contrasto con la decisione 5;
- non espone metà dei campi necessari.

**Beneficio aggiuntivo**: il caricamento massivo iniziale (80.211 pneumatici + 2.944 cerchi + 115
accessori) diventa un `INSERT … SELECT` dalla view, senza duplicare il mapping.

## 2. `ar_sotgru` dei ricambi = 1669, non 1699

Il valore `1699` **non esiste** in `artico`. Tutte e 3.163 le righe di `WheelsNet.dbo.Spares` hanno
`ProductTypeId = 16` e `ProductSubTypeId = 69` ("RUOTINO EMERGENZA"), e le 5.618 righe già presenti
in `artico` stanno su `1669`. Usare 1699 avrebbe creato un sottogruppo nuovo e migrato lì i ricambi
esistenti al primo upsert.

La view calcola comunque `1600 + ProductSubTypeId` invece di cablare 1669, così resta corretta se
in futuro nascono altri sottotipi di ricambio.

## 3. Misure scritte ×100

**Percorso della decisione**: inizialmente scelta la scrittura raw, poi rovesciata quando è emerso
che le colonne di destinazione sono `decimal(18,**0**)`, cioè **interi**.

Con scala 1 non si sarebbe scritto "8,5 invece di 850": si sarebbe scritto **9**. La perdita
misurata:

| Campo | Righe con decimali | Esempio |
|---|---|---|
| `MaxBoreDiam` → `ar_cerformax` | 71.448 su 82.413 (86,7%) | 72,60 → 73 |
| `Width` → `ar_cermis` | 35.888 (43,5%) | 8,50 → 9 (un 8,5J diventa un 9J) |
| `Pcd1` → `ar_cerinter1` | 12.952 | 114,30 → 114 |
| `Offset` → `ar_ceret` | 1.817 | 32,50 → 33 |
| `Diameter` pneumatici | 628 | 17,5" → 18 |

×100 è anche il formato del 97% dell'anagrafica esistente e del 100% delle righe create di recente.
Verificato su articoli reali: `Pcd1` 114,30 → `ar_cerinter1` **11430**.

Restano **non scalati** `ar_cerfor` (fori) e `ar_pnindcar` (indice di carico), che in ERP sono `int`
e contengono il valore nudo — verificato su 145.768 righe.

I **pesi** sono `decimal(27,9)` e vanno scritti raw.

In ogni view la scala è isolata in un `CROSS JOIN (SELECT scala = 100) k` marcato `[SCALA]`: si
cambia in un punto solo per view.

## 4. UPDATE conservativo

Le colonne senza sorgente in WheelsNet non vengono toccate in UPDATE, e ricevono un default solo in
INSERT:

- `ar_cersotgrup` (76.567 righe valorizzate) e `ar_cermarcveic1..5` (75.439) sono curati a mano
  nell'ERP: sovrascriverli li avrebbe azzerati.
- `ar_codalt` e `ar_hhean` si aggiornano solo se la sorgente ha un valore **reale**, tramite
  `COALESCE(s.<col>, a.<col>)`.

Il caso `ManufacturerCode = Id` è emerso **durante la validazione**, non in analisi: l'accessorio
`ZMG0000026001` ha `ManufacturerCode` uguale al proprio `Id`, e propagarlo avrebbe sovrascritto il
codice fornitore vero `26001`. Riguarda **1.036 accessori su 5.698** (18%), 6 cerchi e 3 ricambi.
Stesso trattamento già previsto per `Ean = Id` (8.650 pneumatici, 4.340 accessori).

## 4-bis. `ar_pesolor` = `ar_pesonet`, il lordo non viene propagato

**Errore corretto in corso d'opera.** Le view scrivevano inizialmente
`ar_pesolor = GrossWeightKg`, dedotto dal nome del campo senza verificare il dato.

La verifica mostra che in `artico` i due campi sono **identici su 245.075 righe su 245.075**, in
tutte e cinque le classi merceologiche, zero eccezioni. Anche `SpNtsArticoUpdate` li allinea
(`ar_pesonet = ar_pesolor = WeightKg`). L'ERP non distingue lordo e netto.

In WheelsNet invece differiscono:

| Sorgente | `Gross > Net` |
|---|---|
| `Wheels` | 76.795 su 82.413 (93%) |
| `Spares` | 3.163 su 3.163 (100%) |
| `Tyres` | 0 |
| `Accessories` | 0 |

Propagare il lordo avrebbe introdotto su ~80.000 articoli una differenza mai esistita nell'ERP.
Le view calcolano quindi un unico valore (`CROSS APPLY … peso`) e lo scrivono in entrambe le
colonne. Se in futuro serve il lordo vero per le spedizioni, si tocca solo quel `CROSS APPLY`.

## 5. Nessun filtro su `PubblicationTypes`

Se l'`@id` esiste nella tabella sorgente, l'articolo va nell'ERP. Se non esiste: **no-op
silenzioso**, zero righe toccate e nessun errore, così la stored è sicura da chiamare in loop o da
un trigger senza gestione delle eccezioni.

## 6. `UPDATE` + `INSERT`, non `MERGE`

Si ricalca il pattern di `WheelsNet.dbo.SpNtsBrandsUpsert`, l'unico oggetto che oggi scrive con
successo sul linked server. `MERGE` verso un linked server con 4 trigger attivi è fragile, e una
transazione esplicita richiederebbe MSDTC. Nessuna transazione esplicita, come nella SP di
riferimento.

Nota: il vecchio `_UpsertArticoCodart` usa `MERGE` ed elenca 250 colonne. Non serve: `artico` non ha
**nessuna** colonna NOT NULL priva di default, quindi bastano i ~40 campi significativi.

## 7. Ambito limitato a `srvsql.dbtopruote`

Le altre ditte (`srvsql.revorim`, `srvsql.automotive`), che `WheelSystemsExport.dbo.SpNtsArticoUpdate`
allinea a valle per `ar_hhean` / `ar_codalt` / pesi, restano fuori scope. Da verificare, quando le
nuove stored andranno a regime, che quel job non entri in conflitto.

## 8. Firma con `@debug` opzionale

`@id VARCHAR(50), @debug BIT = 0`. La chiamata a parametro singolo resta valida come richiesto.
Con `@debug = 1` la stored non scrive: restituisce la riga calcolata affiancata a quella presente in
`artico`. Serve a validare il mapping in produzione **senza** autorizzazione a scrivere.
