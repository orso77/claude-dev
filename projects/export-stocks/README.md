# Progetto export-stocks — migrazione export "stock 356" a modalità revorim

Migrazione dell'export stock "356 spare wheels" dal **vecchio server** (`77.81.228.147`,
vista + app `Wheels.Win.Exports exportbycustomer`) al **nuovo server** (`192.168.100.52`,
modalità "revorim": stored procedure parametrica per cliente eseguita da `Utilities.SqlToFile`).
I file finali vanno nella cartella `356automotive` con **la stessa identica struttura** dei vecchi.

Piano completo: `C:\Users\Orso\.claude\plans\nuovo-progetto-export-stocks-c-claude-de-melodic-bentley.md`

## Stato

- **Fitment**: già migrato (`WheelSystemsExport.dbo.SpFitmentSpares_356V001..V007` → file `FitmentSpares_356V00x.csv` già presenti in `356automotive/`).
- **Stock**: SP create in **locale** e in **produzione** (`192.168.100.52` = server `wile-2025`) e validate. ✅
- **Orchestrazione `.bat`** nuovo server: `03-356automotive-stock.bat` creato (modello revorim). ✅

### Validazione in produzione (192.168.100.52)
- Dipendenze presenti; nessuna collisione di nomi (i 3 oggetti erano assenti).
- Contratto `INSERT...EXEC` (16 colonne di `SpAutPriceSpares`) OK; campione 4s/RU000KOE0001S → `ListPrice=225.00`, `NetPrice=112.50` (= vecchio CSV).
- Conteggi/brand per cliente = identici ai vecchi file: 4s **793**; tagliabue (Nuvolari) **793**; eurawheels **793 SPARE WHEELS + 346 BASIC = 1139**.
- **Unica differenza**: `ProductDescr` è in MAIUSCOLO e senza virgole interne perché la sorgente del nuovo modello (`WheelsNet.dbo.Spares.Descr`) è già così normalizzata — non correggibile nella SP (fix eventuale a monte, nell'import di `Spares`).

### Punti da confermare (`03-356automotive-stock.bat`)
- **Base FTP di destinazione**: assunta `\\192.168.100.100\ftp\356automotive\<cliente>\` (modello revorim). Da confermare share/percorso reale.
- **Dir output locale**: `C:\App\SqlToCsv\output\356automotive\`.
- **Naming cartelle cliente**: mantenuto quello **vecchio** (`<cliente>`, es. `4s`) con i nomi-file di destinazione esatti dei vecchi file (non la convenzione revorim `<nome>-<id>`), per non rompere gli importer a valle.
- I file **fitment** sono attesi già generati in `C:\App\SqlToCsv\output\356automotive\` (come nel vecchio flusso, non li rigenera questo bat).
- Le righe disabilitate nel vecchio bat (`mak`/`extradeon` CompDistr, `carpart`, `keskin`) restano `rem` e referenziano ancora il vecchio comando (storiche). CompDistr non è stata implementata.

## Oggetti creati (DB locale `.\WheelSystemsExport`) — script in `sql/`

| Oggetto | File | Note |
|---|---|---|
| `dbo.FnDecimalFormat2` | `sql/FnDecimalFormat2.sql` | Formato `0,00` mantenendo lo zero (l'esistente `FnDecimalFormat` azzera → `''`). |
| `dbo.SpStock_356V001` | `sql/SpStock_356V001.sql` | Standard, **17 colonne**. Usata da quasi tutti i clienti. |
| `dbo.SpStock_356NuvolariV001` | `sql/SpStock_356NuvolariV001.sql` | **13 colonne** (senza dimensioni/pesi). Usata da `tagliabue` (53000577). |
| `dbo.SpStock_356V008_Nsk` | `sql/SpStock_356V008_Nsk.sql` | Variante NSK (`BrandId 1000001`), cliente 53001952. |

Tutti con `CREATE OR ALTER` (re-deployabili).

### 2026-08-07 — campi `Spares` aggiunti in coda (tutte e 3 le SP → 30 colonne)

`Img1..Img5, Width, Diameter, Holes, Pcd1, MadeIn, NetWeightKg, GrossWeightKg, MaxLoad,
Tyre, BoxSize, Material, TrunkSize` da `WheelsNet.dbo.Spares`, con backup `_202608071330`
delle 3 SP. Dettaglio criteri, campi esclusi perché già presenti e verifiche:
[`campi-spares-aggiunti-20260807.md`](campi-spares-aggiunti-20260807.md).
**Il tracciato dei CSV a valle cambia.**

### Aperto — accessori NSK assenti dall'export

`SpStock_356V008_Nsk` non esporta i 18 accessori NSK (sacche/cric/chiavi, es. `SNSK000BAG001`):
stanno in `WheelsNet.dbo.Accessories`, non in `Spares`, e la SP filtra su `SpAutPriceSpares`.
Analisi e fix proposto: [`nsk-accessori-mancanti-20260807.md`](nsk-accessori-mancanti-20260807.md).

## Meccanismo chiave

Il sottoinsieme prodotti per cliente **non** è un filtro brand fisso: deriva dai prodotti
**prezzati per il cliente**. `WheelsNet.dbo.SpAutPriceSpares @contactId=@customerId, @includeZeroNetPrice=0`
ritorna solo i prodotti con `NetPrice>0` (applicando già le esclusioni). Un **INNER JOIN** su quel
result set produce automaticamente il sottoinsieme brand corretto (es. 4s→349, cora→348, eurawheels→349+380).
Il `WHERE p.BrandId IN (348,349,380)` limita solo all'universo "356 spare wheels".

## Sorgenti dati (modello Automotive)

- Master/stock/brand/pfu: `WheelSystemsAutomotive.dbo.Products / Brands / ProductStocks (wh 356/357, cap 40) / NtsProducts (PFUGT02)`
- Descrizione/dimensioni/pesi: `WheelsNet.dbo.Spares` (`Descr, TrunkSize, BoxSize, NetWeightKg, GrossWeightKg`)
- ListPrice + Price netto cliente: `WheelsNet.dbo.SpAutPriceSpares`

## Verifiche eseguite (locale)

- Creazione/compilazione senza errori. SP eseguibili (`EXEC` ok).
- Formattazione: `0,00` / `40,00` / `16,50` (FnDecimalFormat2) e `112,5` / `121` / `101,25` (Price `0.##`). ✅
- Tracciato colonne: 17 (standard) e 13 (nuvolari), nomi/ordine identici ai vecchi CSV. ✅
- **GAP locale**: `WheelSystemsAutomotive` quasi vuoto in locale → le SP girano ma tornano ~0 righe / Price=0.
  La validazione dei **valori** va fatta in **produzione** (192.168.100.52), dove il modello è popolato.

## Orchestrazione `.bat` (nuovo server) — `03-356automotive-stock.bat`

File generato: `03-356automotive-stock.bat` (nella root del progetto), trasformando il vecchio
`356sparewheels-stock-customer.bat` sul modello di `03-Stock_RevorimV003.bat`. Per ogni cliente:
```
app\Utilities.SqlToFile WheelSystemsExport "exec SpStock_356V001 <companyId>" "...\output\356automotive\<companyId>_<cliente>.csv"
copy "...\<companyId>_<cliente>.csv"          "\\...\356automotive\<cliente>\...-stock.csv"
copy "...\FitmentSpares_356V00x.csv"          "\\...\356automotive\<cliente>\sparewheels-fitment-list.csv"
```

### Mappatura clienti (dal vecchio `.bat`) — variante stock e fitment

Tutti usano `SpStock_356V001` (standard) tranne dove indicato. Fitment = `FitmentSpares_356V002_356.csv`
salvo diversa nota. CompDistr (`mak`, `extradeon`) resta **esclusa** come nel `.bat` attuale.

| companyId | cliente | variante stock | fitment | note |
|---|---|---|---|---|
| 53000522 | 4s | V001 | V002_356 | |
| 53000541 | bracchi | V001 | V002_356 | |
| 53000046 | campelli | V001 | V002_356 | |
| 53000534 | grassini | V001 | V002_356 | |
| 53000706 | happygomme | V001 | V002_356 | |
| 53000006 | md | V001 | V002_356 | inviato anche a pneutec 53000431 (ftp) |
| 53000051 | nizzoli | V001 | V002_356 | |
| 53000442 | palmeri | V001 | V002_356 | |
| 53000366 | picone | V001 | V002_356 | |
| 53000711 | scarpinato | V001 | V002_356 | |
| 53000008 | vr | V001 | V002_356 | |
| 53000557 | gmp | V001 | V002_356 | |
| 53000640 | elite | V001 | V002_356 | |
| 53000805 | cora | V001 | V005_nuvolari | stock.csv (no prefisso) |
| 53000661 | giotto | V001 | V002_356 | |
| 53000732 | favilli | V001 | V002_356 | |
| 53000539 | tonin | V001 | V002_356 | |
| 53000705 | agcompany | V001 | V002_356 | |
| 53001404 | toptyre | V001 | V002_356 | |
| 53001408 | futurpol | V001 | V002_356 | stock.csv |
| 53001485 | conean | V001 | V002_356 | |
| 53001499 | tyroo | V001 | V002_356 | + ftp cliente |
| 53000007 | afruote | V001 | V002_356 | |
| 53001465 | dileo | V001 | V002_356 | |
| 53001517 | aliservice | V001 | V002_356 | |
| 53001521 | mcwheels | V001 | V002_356 | |
| 53001524 | picoportal | V001 | V007_KwPatternCenterBoreLoad | fitment file `-v02` |
| 53000340 | masserut | V001 | V002_356 | |
| 53001449 | wheelsrapid | V001 | V002_356 | |
| 53001553 | bonansone | V001 | V002_356 | |
| 53000539 | toningomme | V001 | V002_356 | stesso companyId di tonin |
| 53001756 | wsptrading | V001 | V002_356 | |
| 53000736 | pneusin | V001 | V002_356 | |
| 53001764 | eurawheels | V001 | V002_356 + V006_basic | anche `sparewheels-fitment-list-basic.csv` |
| 53001719 | cartercash | V001 | V002_356 | |
| 53001765 | givawheels | V001 | V002_356 | |
| 53001247 | pendin | V001 | V002_356 | |
| 53000216 | guglielmi | V001 | V002_356 | |
| 53001857 | hispania | V001 | V005_nuvolari | |
| 53001860 | projex | V001 | V005_nuvolari | |
| 53000824 | donadello | V001 | V002_356 | |
| 53001856 | pitstop | V001 | V002_356 | |
| 53000361 | falcopneus | V001 | V002_356 | + ftp cliente |
| 53001868 | mgm | V001 | V002_356 | |
| 53000746 | tyreresort | V001 | V002_356 | |
| 53001885 | giongo | V001 | V002_356 | |
| 53001893 | tyrelab | V001 | V002_356 | |
| 53001214 | mondo | V001 | V002_356 | |
| 53001913 | oliosb | V001 | (solo fitment V002_356ktype) | |
| 53001481 | taurus | V001 | V002_356 | stock `taurus-stock.csv` |
| 53000577 | tagliabue | **Nuvolari V001** | (nessun fitment) | usa `SpStock_356NuvolariV001` |
| 53001933 | tagliabue-negozi | V001 | (nessun fitment) | |
| 53001940 | ravasi | — | — | va all'FTP **revorim**, non 356 |

Esclusi/disabilitati nel `.bat` attuale: `carpart` (escluso 31/01/2025), `mak`/`extradeon` (CompDistr, no fitment), `keskin` (commentato).
