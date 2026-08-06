# `srvsql.DBTOPRUOTE.dbo.artico` — struttura, evidenze e mappatura da WheelsNet

Tutte le evidenze sono state raccolte il **2026-08-06** in **sola lettura** su `192.168.100.52`
(server `wile-2025`) e sul linked server `SRVSQL`. Nessuna scrittura.

## 1. La tabella di destinazione

| | |
|---|---|
| Percorso | `srvsql.DBTOPRUOTE.dbo.artico` |
| Ditta usata | `codditt = 'TOPRUOTE'` (unica presente) |
| Colonne | 278 |
| Chiave | PK clustered `artico_i123_0` su **(`ar_codart`, `codditt`)** |
| Colonne NOT NULL senza default | **0** |
| Trigger attivi | `BusSyncArtico`, `BusSyncArticoUpdate`, `BusSyncArtico356`, `BusSyncArticoUpdate356` |

**Conseguenza pratica**: siccome ogni colonna NOT NULL ha un default constraint, l'`INSERT` può
elencare solo i ~40 campi significativi invece dei 250 di `_UpsertArticoCodart`.

I trigger `BusSync*` accodano una riga in `SyncQueue` (`Oper=1` insert, `Oper=3` delete, tabella
`b_artico`, agent `top`) per ogni riga toccata, saltando gli articoli con `ar_descr` che inizia per
`np`/`n.p`/`n. p`/`IMPORT` o con `ar_blocco = 'S'`. Non fanno scattare nulla se
`APP_NAME() = 'connector 1.0'`.

## 2. Distribuzione per gruppo/sottogruppo

| `ar_gruppo` | `ar_sotgru` | Righe in artico | Tipologia |
|---|---|---|---|
| 2 | 201 | 145.768 | Pneumatici |
| 4 | 401 | 78.938 | Cerchi in lega |
| 8 | 801 | 1.856 | Cerchi in ferro |
| 16 | 1669 | 5.618 | **Ricambi / ruotini** |
| 16 | altri `16xx` | 12.893 | Accessori |

`ar_sotgru = 1699` **non esiste**. I ricambi stanno su `1669` = `16` + `ProductSubTypeId 69`
("RUOTINO EMERGENZA"), che è il sottotipo di **tutte** le 3.163 righe di `WheelsNet.dbo.Spares`.

### Copertura attuale rispetto a WheelsNet

| Sorgente | Pubblicati | Presenti in artico | Mancanti |
|---|---|---|---|
| `Tyres` | 134.396 | 54.185 | **80.211** |
| `Wheels` | 55.676 | 52.732 | **2.944** |
| `Spares` | 3.163 | 3.163 | 0 |
| `Accessories` | 5.698 | 5.583 | **115** |

## 3. La scala ×100 delle misure

Le colonne geometriche di `artico` sono `decimal(18,**0**)` — **interi, zero decimali**. NTS ci
convive memorizzando il valore **moltiplicato per 100**. Verificato sul dato reale:

| WheelsNet | artico | Nota |
|---|---|---|
| `Pcd1` 114,30 | `ar_cerinter1` **11430** | |
| `Width` 6,50 | `ar_cermis` **650** | |
| `MaxBoreDiam` 67,00 | `ar_cerformax` **6700** | |
| `Diameter` 16,00 | `ar_cerdiam` **1600** | |
| tyre 215/65R16 | `ar_pnmis` **21500**, `ar_pnspal` **6500**, `ar_pndiam` **1600** | |
| `Holes` 5 | `ar_cerfor` **5** | `int`, **mai** scalato |
| `LoadIdx1` 98 | `ar_pnindcar` **98** | `int`, **mai** scalato |

Diffusione: 97,6% delle righe cerchi e 97,8% dei pneumatici sono ×100; il residuo è legacy raw.
Tutte le righe create di recente sono ×100.

Scrivere raw non era praticabile: avrebbe **arrotondato** 71.448 cerchi su 82.413 sul foro centrale
(72,60 → 73), 35.888 sulla mezza misura di canale (8,50 → 9), e 628 pneumatici sul diametro
(17,5" → 18).

I **pesi** sono invece `decimal(27,9)`: `ar_pesonet` / `ar_pesolor` vanno scritti **raw**, 14,75 kg
resta 14,75.

## 4. Costanti invarianti (su tutte le ~245.000 righe)

`ar_codiva = 122` · `ar_contros = 1006` · `ar_unmis = 'NR'` · `ar_prorig = 'MC'` ·
`ar_paeorig = 'IT'` · `ar_paeorigv = 'IT'` · `ar_conver = 1` · `ar_qtacon2 = 1` ·
`ar_umintra2 = 'P'` · `ar_forn = 0` · `ar_reparto = 0` · `ar_tipo` vuoto.

Queste sono le uniche che **differiscono dal default constraint** e vanno quindi scritte
esplicitamente. Tutte le altre (~140) arrivano dai default e coincidono già con il dato osservato:
`ar_stalist='S'`, `ar_flricmar='R'`, `ar_polriord='G'`, `ar_tipscarlotx='M'`, `ar_consmrp='S'`,
`ar_umwebvis='SSSSSSSSSS'`, `ar_gpvvis='S'`, `ar_datini='1900-01-01'`, `ar_datfin='2099-12-31'`,
`ar_xcheck1..10='N'`, `ar_umsegno5..8=1`, ecc.

### Contropartite per tipologia

| `ar_sotgru` | `ar_controp` | `ar_controa` | `ar_claprov` |
|---|---|---|---|
| 201 | 5369 | 5373 | 2 |
| 401 | 5370 | 5374 | 4 |
| 801 | 5371 | 5375 | 8 |
| 16xx | 5372 | 5376 | 16 |

## 5. Convenzioni di formato

- **Descrizione**: `ar_descr = LEFT(Descr, 40)` + `ar_desint = SUBSTRING(Descr, 41, 40)`.
  Il prefisso di tipologia (`COP. `, `CER. L. `, `CER. F. `, `ACC. `, `KIT `) è **già dentro**
  `Descr` in WheelsNet. Oltre gli 80 caratteri la descrizione viene troncata: è la convenzione NTS,
  ma riguarda 15.351 cerchi, 2.702 ricambi, 1.254 pneumatici e 837 accessori.
- **Orari**: `ar_oragg` e `ar_orins` sono `int` in formato **HHMM** (range osservato 0–2035), non
  datetime. `ar_datins` è la sola data (mezzanotte).
- **`ar_famprod`**: `varchar(4)` = `Brands.Id` di WheelsNet (lunghezza max 4, ci sta).
- **`ar_pndemo`**: dominio `{'S','N'}`.

## 6. Valori placeholder da NON propagare

| Campo sorgente | Casi | Effetto se propagato |
|---|---|---|
| `Ean = Id` | 8.650 pneumatici, 4.340 accessori, 21 cerchi, 8 ricambi | `ar_hhean` riceve il codice articolo al posto dell'EAN |
| `ManufacturerCode = Id` | **1.036 accessori**, 6 cerchi, 3 ricambi | `ar_codalt` sovrascrive il codice fornitore vero (visto su `ZMG0000026001`: `26001` → `ZMG0000026001`) |
| `ManufacturerCode` vuoto | 10.809 pneumatici, 364 cerchi | `ar_codalt` azzerato |

Le view restituiscono `NULL` in tutti questi casi e le stored usano
`COALESCE(s.<col>, a.<col>)`, così il valore ERP esistente viene conservato.

## 7. Campi senza sorgente in WheelsNet

`ar_cersotgrup` (76.567 righe valorizzate, dominante `'AUTOVETTURA'`) e `ar_cermarcveic1..5`
(75.439 righe, dominante `'CATALOGO'`) sono curati lato ERP. Le stored li scrivono **solo in
INSERT** con il valore dominante; in UPDATE non li toccano.

## 8. Mappatura campo per campo

### Comune a tutte le tipologie

| artico | Sorgente WheelsNet |
|---|---|
| `codditt` | `'TOPRUOTE'` |
| `ar_codart` | `Id` |
| `ar_descr` | `LEFT(Descr, 40)` |
| `ar_desint` | `SUBSTRING(Descr, 41, 40)` |
| `ar_codalt` | `ManufacturerCode`, se non vuoto e diverso da `Id` |
| `ar_hhean` | `Ean`, se non vuoto e diverso da `Id` |
| `ar_famprod` | `BrandId` |
| `ar_pesonet` | `NetWeightKg`, altrimenti fallback |
| `ar_pesolor` | `GrossWeightKg`, altrimenti `NetWeightKg`, altrimenti fallback |
| `ar_datins` / `ar_orins` | data e HHMM di esecuzione (solo INSERT) |
| `ar_ultagg` / `ar_oragg` | data-ora e HHMM di esecuzione (INSERT e UPDATE) |

I fallback peso (per diametro nelle prime tre tipologie, per sottotipo negli accessori) sono ripresi
tali e quali da `ViewNtsSyncProducts`.

### Pneumatici (`ViewNtsSyncTyres`)

`ar_gruppo=2` · `ar_sotgru=201` · `ar_codnomc='4011.10.00'` ·
`ar_pnmis = Width×100` · `ar_pnspal = AspRatio×100` · `ar_pndiam = Diameter×100` ·
`ar_pnindcar = LoadIdx1` · `ar_pncodvel = LEFT(SpeedId,2)` · `ar_pnsotgrup = Category` ·
`ar_pnstag` = `SUMMER→summer`, `WINTER→winter`, `4 SEASONS→4season` · `ar_pndot = Dot` ·
`ar_pneupresistrot = LEFT(EcoRollResist,1)` · `ar_pneupaderbagn = LEFT(EcoWetGrip,1)` ·
`ar_pneuprumordb = EcoNoiseDb` · `ar_pneuprumorliv = EcoNoiseLev` ·
`ar_pneuprumorliv2 = EcoNoiseLev2` · `ar_pnrating = 0` · `ar_pndemo = Demo ? 'S' : 'N'`.

### Cerchi (`ViewNtsSyncWheels`)

`ProductTypeId=4` → `ar_gruppo=4`, `ar_sotgru=401`, `ar_codnomc='8708.70.50'`;
`ProductTypeId=8` → `ar_gruppo=8`, `ar_sotgru=801`, `ar_codnomc='8708.70.91'`.
`ar_cermis = Width×100` · `ar_cerdiam = Diameter×100` · `ar_cerfor = Holes` ·
`ar_cerinter1..3 = Pcd1..3×100` · `ar_ceret = Offset×100` · `ar_cerformax = MaxBoreDiam×100` ·
`ar_cercolor = Color`. Solo in INSERT: `ar_cersotgrup='AUTOVETTURA'`, `ar_cermarcveic1='CATALOGO'`.

### Ricambi (`ViewNtsSyncSpares`)

`ar_gruppo=16` · `ar_sotgru = 1600 + ProductSubTypeId` (oggi sempre 1669) ·
`ar_codnomc = '8708.70.50'` se sottotipo 21, altrimenti `'8708.70.91'` ·
`ar_accsotgrup = ProductSubTypes.Descr` ·
`ar_cermis = Width×100` · `ar_cerdiam = Diameter×100` · `ar_cerfor = Holes` ·
`ar_cerinter1 = Pcd1×100` · `ar_pndiam = Diameter×100`.

In artico i ricambi hanno oggi tutte le `ar_cer*` a zero: popolarle è un miglioramento voluto.

### Accessori (`ViewNtsSyncAccessories`)

`ar_gruppo=16` · `ar_sotgru = 1600 + ISNULL(ProductSubTypeId, 1)` (243 accessori senza sottotipo
finiscono su 1601, dove ci sono già 423 righe) ·
`ar_codnomc = '9026.20.20'` per i sottotipi TPMS 77/78/95, altrimenti `'8708.70.99'` ·
`ar_accsotgrup = ProductSubTypes.Descr`. Nessuna misura geometrica.

## 9. Errori presenti in `ViewNtsSyncProducts` (non replicati)

| Campo | Problema |
|---|---|
| misure `ar_pn*` / `ar_cer*` | non applica la scala ×100 |
| `ar_oragg` | valorizzato con un `datetime` invece che HHMM intero |
| `ar_accsotgrup` | sempre `NULL`, mentre in ERP è valorizzato su 17.677 righe |
| `ar_pneuprumorliv` | forzato a 0 ignorando `EcoNoiseLev` |
| `ar_pnrating` | forzato a 1 mentre in ERP il valore corrente è 0 |
| `ar_codalt` / `ar_hhean` | sempre stringa vuota, mentre le sorgenti hanno i dati |
| `ar_sotgru` | calcolato con `FORMAT()` → stringa `'0201'`, mentre la colonna è `smallint` |
| filtro | `PubblicationTypes > 0`, che esclude articoli comunque da inviare |

## 10. Prerequisito: brand mancanti in `tabcfam`

Nove brand usati da prodotti pubblicati non esistono nell'anagrafica famiglie dell'ERP:
**ATR** (ANTERA), **CBF**, **EVT** (EVENT), **EZS** (EZ SENSOR), **JP** (JAPANPARTS),
**KR** (KREMER), **ORF** (ORIGINALE FORD), **ORSS** (ORIGINALE SSANGYONG), **ZZZ** (Altro).

Va lanciata `WheelsNet.dbo.SpNtsBrandsUpsert` prima del primo upsert reale.

## 11. Esito della validazione (2026-08-06, sola lettura)

Le 4 view sono state eseguite come `SELECT` e confrontate con `artico` sugli articoli campione.
Tutte le misure ×100 coincidono **esattamente** con il dato ERP esistente:

| Articolo | Campo | View | artico |
|---|---|---|---|
| `ZZ00000849390` | `ar_pnmis`/`ar_pnspal`/`ar_pndiam` | 21500 / 6500 / 1600 | identico |
| `CL00000457062` | `ar_cermis`/`ar_cerdiam`/`ar_cerinter1`/`ar_ceret`/`ar_cerformax` | 900 / 2000 / 12000 / 4000 / 7410 | identico |
| `ZAC00000ORP0S` | `ar_cerinter1`/`ar_cerformax` | 11430 / 7160 | identico |

Differenze attese e volute rispetto all'attuale contenuto ERP:

- `ar_pnindcar`: la view valorizza (98) dove l'ERP ha 0 su tutte le righe.
- `ar_pndemo`: la view scrive `'N'`/`'S'` dove l'ERP ha `NULL` su 145.128 righe.
- `ar_pesolor`: la view usa `GrossWeightKg` (10,5) dove l'ERP aveva il peso netto (10,0).
- Ricambi: le `ar_cer*` passano da 0 ai valori reali.
- `ar_cercolor`: WheelsNet è autoritativo (`SILVER` contro `SUPERPOLISH` su `ZAC00000ORP0S`).
- `ar_descr`: WheelsNet normalizza in maiuscolo e senza virgole interne
  (`M12X1 25X35 3` contro `M12X1,25X35,3`). È una differenza a monte, nell'import di WheelsNet.
