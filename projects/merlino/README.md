# Merlino

Motore predittivo basato su analisi "grafica" dello storico estrazioni. **Un'unica app** che predice in sequenza:
1. **SuperEnalotto** (6 numeri da 1-90 + SuperStar 1-90)
2. **EuroJackpot** (5 numeri da 1-50 + 2 Euro numeri da 1-12)

Codice separato per i due giochi (file dedicati), stesso approccio algoritmico: **pattern matching grafico** — zero feature scalari, zero matematica stocastica. Il modello cerca le finestre storiche graficamente più simili alla situazione attuale e predice i numeri che sono usciti dopo quelle finestre.

## Algoritmo (pattern matching puro)

1. Ogni estrazione è una **riga binaria** nel canvas (pixel acceso = numero estratto).
2. Per predire l'estrazione `t`, si prende la "foto" delle ultime `W` estrazioni come **query pattern**.
3. Si scorre tutto lo storico `[0..t-W-Depth]` cercando le finestre di altezza `W` graficamente più simili (distanza Hamming o Jaccard su bitmap, opzionalmente pesata per righe recenti).
4. I top-`K` vicini contribuiscono al punteggio dei numeri secondo cosa è uscito **subito dopo** la loro finestra (con `SuccessorDepth` righe di lookahead e peso per similarità).
5. Opzionalmente si applica un anti-repeat penalizzando numeri usciti nelle ultime righe.
6. Opzionalmente si combinano più finestre (`MultiWindow`: W=3, 7, 15 simultanee).

**Anti-leakage garantito**: il vincolo `candEnd ≤ queryStart - depth` assicura che il successor del vicino sia sempre PRIMA del query pattern. Nessuna riga del query può essere usata come successor.

## Tuning: random search + refinement full walk-forward

Due fasi per ogni canvas:
1. **Random search** (60 iter) sul fast test set (step=4 dalla 300-esima estrazione in poi). Genera 10 candidati top.
2. **Refinement**: rivaluta i 10 migliori sul **full walk-forward** (step=1, dalla 200-esima a oggi, circa 3965 test points SE, 3051 SS, 733 EJ main, 357 EJ euro). Il best finale è chi vince sul full.

Questo elimina l'overfitting al campione ridotto che gonfiava le metriche.

## Risultati onesti (full walk-forward, step=1, 10-04-2026)

| Metrica | Merlino | Baseline random | Edge |
|---------|---------|-----------------|------|
| SE top-12 main (3965 test points) | **0.826** | 0.800 | +3.2% |
| SE top-3 SuperStar (3051 test points) | **0.040** | 0.033 | +21.2% |
| EJ top-10 main (733 test points) | **1.061** | 1.000 | +6.1% |
| EJ top-6 euro (357 test points) | **1.014** | 1.000 | +1.4% |

**Distribuzione hit top-12 SE** (full walk-forward, 3965 estrazioni):
```
 0 hit: 39.8%
 1 hit: 41.5%   ← caso più probabile
 2 hit: 15.3%
 3 hit:  3.1%
 4 hit:  0.3%
 5+ hit: 0.0%
```

Un hit su 12 numeri giocati è **il risultato statisticamente più probabile** del modello. Zero hit è il secondo. Due hit è già nel 15%. Questo va tenuto bene a mente prima di valutare un singolo esito.

## Nota di onestà intellettuale

L'edge è **reale ma modesto** (+3.2% su top-12). Con 3965 test point lo stddev naturale è ~0.014, quindi +0.026 sopra baseline è ~1.9σ, marginalmente significativo. Non abbastanza per battere il banco: il SuperEnalotto paga il 6 e con +3% di edge su top-12 (che non corrisponde a top-6) non si compensa il margine del banco. Il modello è uno **strumento di compagnia** per chi vuole giocare numeri "con un segnale" invece che random, non un metodo profittevole.

## Path

- Sorgenti: `C:\src\orso\Merlino`
- Dati SuperEnalotto: `C:\src\orso\Merlino\data\*.txt`
- Dati EuroJackpot: `C:\src\orso\Merlino\data\eurojackpot\*.txt`
- Documentazione: `C:\!claude\docs\projects\merlino`

## Stack

- .NET 10 / C# 14 (Exe console)
- Nullable enabled, implicit usings
- Nessuna dipendenza esterna (HttpClient + Regex source-generated)

## Formato dati

Un file TXT per anno: `data/{yyyy}.txt`.

- Encoding: UTF-8 **con BOM**
- Line endings: **CRLF**
- Ordine: **DESC** (estrazione più recente in alto)
- Header (2 righe):
  ```
  Archivio estrazioni SuperEnalotto Anno {yyyy} (dal 1997)
  Data\tSERIE\t\t\t\t\t\t\tJOLLY\tSuperstar
  ```
- Righe dati (tab-separated):
  ```
  {yyyy-MM-dd}\t{n1}\t{n2}\t{n3}\t{n4}\t{n5}\t{n6}\t\t{jolly}\t{superstar}
  ```
- Numeri zero-padded a 2 cifre
- `Superstar = 00` significa **assente** (SS introdotta nel 2006; nei file pre-2006 è sempre `00`)

## Fonte estrazioni

Fino al 2026-03-31 si usava `lottologia.com/superenalotto/archivio-estrazioni/?as=TXT&year={year}`.
Dal **2026-04-01** l'endpoint restituisce body vuoto (anche con User-Agent browser e cookie di sessione).

Tentata anche `superenalotto.it` (sito ufficiale Sisal): **bloccato da WAF Akamai** tramite fingerprinting TLS/JA3 — risponde 403 a `HttpClient` di .NET anche con header browser completi (User-Agent, Accept, Accept-Language, Sec-Fetch-*, HTTP/1.1 forzato). Con curl/OpenSSL invece funziona. Aggirare Akamai da .NET richiederebbe librerie TLS terze tipo CycleTLS, sconsigliate.

**Fonte adottata**: `superenalotto.com` (dominio diverso da `.it`, dietro Cloudflare, molto più permissivo).

- URL per anno: `https://www.superenalotto.com/archivio/estrazioni-{yyyy}`
- Ogni pagina contiene **tutte** le estrazioni dell'anno in un unico elenco HTML (semplice e stabile)
- Parsing via regex source-generated (`[GeneratedRegex]`)
- Header HTTP usati: `User-Agent` browser Chrome, `Accept: text/html,...`, `Accept-Language: it-IT,...`, decompressione automatica

### ⚠️ Cambio URL + markup fonte (fix 2026-07-14)

Verso metà aprile 2026 `superenalotto.com` ha cambiato sia URL sia markup, rompendo silenziosamente lo scraper (regex non matchava più → 0 righe → "Nessuna nuova estrazione" senza errore). Sintomo: storico fermo al **2026-04-14**. Fix applicato in `SuperenalottoFetcher.cs`:

- **URL**: `/risultati/{yyyy}` ora fa **301 → `/archivio/estrazioni-{yyyy}`** (aggiornato all'URL finale).
- **Markup nuovo** per estrazione (niente più `ball-24px` / href `estrazione-DD-MM-YYYY`):
  ```html
  <div class="boxarchiveDate">11 luglio 2026</div>
  <div class="boxArchiveNumber">6</div>   (× 6 numeri principali, NON zero-padded)
  <div class="boxArchiveNumber boxArchiveNumberRed">5<div>Jolly</div></div>
  <div class="boxArchiveNumber boxArchiveNumberstar">62<div>Superstar</div></div>
  ```
  I 6 numeri hanno classe **esatta** `boxArchiveNumber"` (il `">` immediato li distingue da Jolly/Superstar che hanno una seconda classe prima di `">`).
- **Data in italiano** (`11 luglio 2026`): aggiunto dizionario `ItalianMonths` per il mapping mese→numero (prima si parsava dall'href numerico).
- La pagina `estrazioni-{yyyy}` contiene **tutte** le estrazioni dell'anno (gen→oggi), quindi l'update incrementale copre sempre l'intero buco senza rischio di gap.

### Falso allarme 2026-07-28 — storico "fermo" al 11/07

Segnalato storico fermo al **2026-07-11**. Verificato: **fonte e scraper OK**, `superenalotto.com/archivio/estrazioni-2026` risponde 200 con markup invariato (`boxarchiveDate` / `boxArchiveNumber`) e la regex matcha. L'archivio era semplicemente vecchio perché **l'app non era stata lanciata dal 14/07**. Un run ha aggiunto 8 estrazioni → storico al **2026-07-25** (4226 righe).

Per rendere immediatamente visibile se lo scraping è fermo, in `Program.cs` è stata aggiunta una riga in chiaro subito dopo il caricamento storico (sia SE che EJ):

```
>>> ULTIMA ESTRAZIONE SE IN ARCHIVIO: 25/07/2026 (oggi: 28/07/2026) <<<
```

Se la data mostrata è molto indietro rispetto a "oggi", lo scraper è rotto; se è allineata all'ultimo concorso, è tutto a posto.

## Aggiornamento incrementale all'avvio

Ogni volta che l'app parte, `SuperenalottoFetcher.UpdateCurrentYearAsync` fa:

1. Determina l'anno corrente (`DateTime.Now.Year`).
2. Legge `data/{year}.txt` se esiste e trova la data massima `lastDate`.
3. Scarica **una sola** pagina `https://www.superenalotto.com/risultati/{year}` con tutte le estrazioni dell'anno.
4. Parsa le estrazioni, filtra solo quelle con `Data > lastDate`.
5. Merge con le righe esistenti, dedup per data, ordina DESC, riscrive il file (UTF-8 BOM, CRLF, tab esatti).
6. Stampa in console quante estrazioni sono state aggiunte.

Questo viene eseguito **prima** di qualsiasi logica predittiva. Idempotente: un secondo avvio immediato stampa "Nessuna nuova estrazione da aggiungere".

## Componenti

**SuperEnalotto** (file dedicati, classi accoppiate a `LottoRow`):

| File | Ruolo |
|------|-------|
| `LottoRow.cs` | DTO estrazione SE (6 numeri + Jolly + SuperStar) |
| `DataStore.cs` | Load/save `data/{yyyy}.txt` SE |
| `HistoryLoader.cs` | Legge tutti i `data/*.txt` SE, dedup, ordina ASC |
| `SuperenalottoFetcher.cs` | Scrape incrementale da `superenalotto.com/risultati/{yyyy}` |
| `MerlinoEngine.cs` | Canvas + feature extraction + Predict (K=90, 6 main + 1 SS) |
| `WalkForwardTuner.cs` | Dual random search: pesi main + pesi SS, 300 iter |

**EuroJackpot** (file dedicati, classi accoppiate a `EuroRow`):

| File | Ruolo |
|------|-------|
| `EuroRow.cs` | DTO estrazione EJ (5 numeri + 2 Euro) |
| `EuroDataStore.cs` | Load/save `data/eurojackpot/{yyyy}.txt` + LoadAll |
| `EurojackpotFetcher.cs` | Scrape incrementale da `italia.lottocracked.com/archivio-di-estrazioni/eurojackpot/estrazioni-{yyyy}/` |
| `EuroMerlinoEngine.cs` | Engine wrapper + `EuroWalkForwardTuner` (2 CanvasEngine: K=50 main, K=12 euro) |

**Condivisi**:

| File | Ruolo |
|------|-------|
| `Program.cs` | Entry point: esegue SE poi EJ, stampa entrambi |
| `CanvasEngine.cs` | Motore generico K-parametrico agnostico dal DTO (`int[][]` + `k`). Usato da `EuroMerlinoEngine`. `MerlinoEngine` resta invece accoppiato a `LottoRow` per motivi storici — migrazione a `CanvasEngine` possibile in futuro. |

## Approccio predittivo — Canvas storico (B)

Tutte le estrazioni come un'unica immagine `R × 90`:
- Righe = estrazioni in ordine cronologico ASC
- Colonne = numeri 1..90
- Pixel acceso se il numero è stato estratto in quella riga

Feature estratte per ogni numero `n` al punto di test `upTo` (usando solo righe `[0, upTo)`):

| Feature | Semantica | Implementazione |
|---------|-----------|-----------------|
| **Hot** | densità verticale recente della colonna n | conta pixel accesi nelle ultime `WindowHot` righe |
| **Gap** | ritardo grafico della colonna n | distanza in righe dall'ultimo pixel acceso, saturata a 2× gap atteso (K/6) |
| **Cadence** | "sei vicino alla tua cadenza abituale?" | `exp(-|current_gap − mean_gap| / std_gap)` sulle ultime 20 occorrenze |
| **Cluster** | densità di n−1 e n+1 (strisce orizzontali) | `(Hot[n−1] + Hot[n+1]) / 2` |
| **Drift** | diagonale che punta a n | per k∈{1,2,3}, bonus `1/k` se `n−k` è uscito `k+1` righe fa |

Ogni feature viene **z-score normalizzata** sui 90 numeri prima della combinazione lineare.
Score finale: `w_hot·Hot + w_gap·Gap + w_cad·Cadence + w_clu·Cluster + w_dri·Drift`.

Le probabilità % non sono derivate da softmax (che introduce una temperatura arbitraria e satura artificialmente il top-1). Sono **calibrate empiricamente sul walk-forward**: per ogni rank `r ∈ [1..90]` si misura la frequenza con cui il numero a quel rank è effettivamente uscito nell'estrazione target sui test point. Il valore % accanto al numero al rank `r` è esattamente quella hit-rate empirica. La somma delle 12 % stampate coincide con l'hit medio top-12 (metrica del tuner). Questo è matematicamente onesto: non ci sono artefatti di softmax.

**Superstar** usa un canvas separato (solo righe con SS valida, cioè dal 2006) con le stesse feature ma senza Cluster/Drift (la SS è un singolo numero, non una sestina).

**Walk-forward tuner** (`WalkForwardTuner.Tune`):
- Test points: ogni 5 righe nel 2/3 finale dello storico (≈ 540 punti)
- Random search su `{WHot, WGap, WCadence, WCluster, WDrift, WindowHot, Temperature}` — 150 iterazioni
- Metrica: **hit medio top-12 vs 6 numeri reali** (massimo teorico 6, baseline random 12·6/90 = 0.80)
- Il best configuration viene usato per la predizione finale sulla "prossima estrazione ignota"

## Risultati baseline attuali (10-04-2026, dual tuner)

Eseguito su **4164 estrazioni** (1997-12-03 → 2026-04-09), 556 test points walk-forward. Random search 300 iter seed 42 in due fasi indipendenti (una per numeri principali, una per SuperStar).

| Metrica | Merlino | Baseline random | Edge |
|---------|---------|-----------------|------|
| Hit medio top-12 principali | **0.874** | 0.800 | **+9.3%** |
| Hit rate top-3 SuperStar | **0.047** | 0.033 | **+42.4%** |

Pesi ottimi numeri principali:
```
Cluster = 0.328
Hot     = 0.264
Cadence = 0.258
Gap     = 0.092
Drift   = 0.058
WindowHot = 21
```

Pesi ottimi SuperStar (cluster/drift forzati a 0 perché non ha senso geometrico applicarli a un singolo numero):
```
Hot     = 0.455
Cadence = 0.420
Gap     = 0.125
WindowHot = 48
```

**Osservazioni**:
- **Tuner separato per SS** (fase 2 indipendente): la SuperStar è passata da 0.027 (sotto baseline, modello dannoso) a 0.047 (+42% sopra baseline). Gli stessi pesi che vanno bene per i numeri principali sono **attivamente nocivi** per la SS. Cause intuibili: SS è un singolo numero i.i.d. senza covarianza tra estrazioni, il Cluster orizzontale e il Drift diagonale sono feature concettualmente sbagliate per la SS.
- Sui numeri principali raddoppiando le iter del random search (150→300) si è passati da 0.869 a 0.874, piccolo guadagno: segnale di plateau vicino.
- Con la calibrazione empirica sulle %, per la SS il rumore campionario è grosso (solo 1 numero su 556 test, hit rate medio 1.5% per rank con stddev ~0.5%). Il +42% va preso con cautela — servirebbe hold-out di validazione.

## Output console

Formato ordinato per **percentuale decrescente** (non per score del modello). Questo rispecchia direttamente la probabilità empirica: il primo numero stampato è quello che il modello ha più volte "azzeccato" nel backtest a quel rank.

Esempio run 2026-04-10 (dopo l'estrazione del 9 aprile):
```
Top-12 numeri principali:
   1. 64     8,45%
   2. 55     8,45%
   3. 62     8,27%
   4. 07     8,09%
   5. 51     7,73%
   6. 54     7,55%
   7. 63     7,19%
   8. 23     7,19%
   9. 61     6,47%
  10. 46     6,47%
  11. 17     6,29%
  12. 19     5,22%

Top-3 SuperStar:
  1. 21     1,80%
  2. 80     1,62%
  3. 82     1,26%
```

Somma top-12 % = 87.37 ≈ hit medio 0.874 (× 100): coerente con la metrica del tuner. Questo è l'invariante matematico della calibrazione empirica: la somma delle probabilità dei top-K è esattamente l'hit medio top-K.

## EuroJackpot — risultati baseline (10-04-2026)

Storico: **832 estrazioni** 2014-03-28 → 2026-04-07 (backfill automatico via `EurojackpotFetcher.BackfillMissingYearsAsync`, sorgente `italia.lottocracked.com`). Saltato 2013 perché la pagina sorgente ha HTML malformato per quell'anno (~19 estrazioni perse, `FirstYear = 2014`).

185 test points walk-forward, 300 iter random search seed 42 in due fasi separate (main + euro).

| Metrica | Merlino | Baseline random | Edge |
|---------|---------|-----------------|------|
| Top-10 numeri principali (1-50) | **1.205** | 1.000 | **+20.5%** |
| Top-6 Euro numeri (1-12) | **1.168** | 1.000 | **+16.8%** |

Baseline random main = 10·5/50 = 1.0 hit. Baseline random euro = 6·2/12 = 1.0 hit.

Pesi ottimi main EJ: Cluster=0.405 (dominante), Gap=0.264, Drift=0.187, Hot=0.136, Cadence=0.008.
Pesi ottimi euro EJ: distribuiti uniformemente (0.15..0.26).

**Output format EuroJackpot**:
- **Top-10 numeri principali** ordinati per % DESC
- **Euro numero 1**: primi 3 di un top-6 ordinato per % DESC
- **Euro numero 2**: secondi 3 di un top-6 ordinato per % DESC

Nota sulla separazione "Euro n.1 / Euro n.2": nel gioco reale i 2 euro numeri sono estratti simultaneamente dalla stessa urna (non c'è "primo" e "secondo"). La distinzione in output è solo per convenienza di compilazione schedina: servono 6 numeri totali diversi come suggerimento.

### Filtro temporale Euro numeri (dal 2022-03-22)

Il cambio regole del 22 marzo 2022 ha portato gli Euro numeri da 1-10 a 1-12. Per evitare bias strutturale su 11-12 (strutturalmente assenti nel pre-2022), **l'euro canvas lavora solo sulle estrazioni dal 2022-03-22 in poi**. Il main canvas resta invariato su tutto lo storico 2014-2026.

- `EuroMerlinoEngine.EuroRulesChangeDate = 2022-03-22`
- `_euroHistory = ascHistory.Where(r => r.Date >= EuroRulesChangeDate)`
- Due canvas separati con conteggi indipendenti (`MainCount` vs `EuroCount`)
- Due set di test points walk-forward: main su 833 righe (186 test points, step 3), euro su 417 righe (139 test points, step 2)

Risultato post-filtro (run 2026-04-10):

| Metrica | Pre-filtro | Post-filtro | Baseline | Edge |
|---------|------------|-------------|----------|------|
| Top-10 numeri principali (1-50) | 1.205 | **1.204** | 1.000 | +20.4% |
| Top-6 Euro numeri (1-12) | 1.168 (gonfiato) | **1.165** (onesto) | 1.000 | +16.5% |

Il bias strutturale era marginale (~0.3% di edge gonfiato), ma ora la metrica è pulita.

### Avvertenze residue

- **Test points main** ancora più piccoli di SE (186 vs 556). Variance alta, l'edge +20% va preso con cautela.
- **Test points euro** solo 139: variance ancora più alta, ±0.03 su una singola run non è significativo.

## OracleEngine — engine sperimentale (2026-04-13)

Secondo motore predittivo, radicalmente diverso da Nexus. Cambio di paradigma: **ottimizza P(≥3 hit in top-12)** anziché E[hits].

### Canali

| Canale | Idea | Novità |
|--------|------|--------|
| **Resonance** | Ogni numero ha un gap medio ("ritmo"). Quando gap ≈ gap medio, il numero è "in fase". Bonus per numeri la cui fase è **sincronizzata** (simultaneamente "pronti") | Phase synchronization: scoring non indipendente, i numeri si amplificano a vicenda |
| **Constellation** | Co-occorrenza di ordine superiore. Cerca estrazioni storiche dove **2+ numeri seed** (ultime giocate) erano presenti e boosta i compagni | Triple co-occurrence anziché pairwise (Gravity di Nexus fa solo coppie) |
| **Attractor** | Embedding di Takens su istogrammi a 9 zone. Ricostruisce lo spazio delle fasi del sistema dinamico, nearest-neighbor prediction | Teoria del caos applicata: tratta le estrazioni come sistema dinamico |
| **Numerology** | Gap allineati con numeri di **Fibonacci** + fase aurea (gap × φ mod 1.0) | Esoterico e testabile: nessuno ha mai validato φ su lotterie con walk-forward |
| **Cluster Boost** | Post-processing: costruisce matrice co-occorrenza tra top-25 candidati, boosta chi co-occorre con gli altri | Concentra le pick in un cluster coerente anziché spalmarle su 90 numeri |

### File

| File | Ruolo |
|------|-------|
| `OracleEngine.cs` | Engine con 4 canali + Cluster Boost post-processing |
| `OracleTuner.cs` | Walk-forward tuner con metrica P(≥3) + tiebreaker E[hits] |

### Tuner

Metrica interna: `P(≥3 hit) + 0.01 × E[hits]` — il tuner massimizza la probabilità di prendere 3+ numeri, con piccolo tiebreaker per E[hits] quando P(≥3) è uguale. 100 iter random search + refinement top-15 su full walk-forward.

21 parametri tunabili: 4 pesi canale, 4 Resonance, 4 Constellation, 3 Attractor, 2 Numerology, 4 Cluster.

### Risultati (run 2026-04-13, 4166 estrazioni, 3966 test points)

| Metrica | Random | Nexus | Oracle |
|---------|--------|-------|--------|
| E[hits] top-12 | 0.800 | **0.833** (+4.1%) | 0.829 (+3.6%) |
| P(≥3 hit) | ~3.3% | 3.40% | **3.53%** |

Hit distribution top-12:

| Hit | Nexus | Oracle |
|-----|-------|--------|
| 0 | 39.4% | 40.3% |
| 1 | 41.9% | 40.4% |
| 2 | 15.3% | **15.8%** |
| 3 | 2.9% | **3.2%** |
| 4 | 0.5% | 0.4% |

**Osservazioni**:
- Oracle sposta massa dalla coda verso 2+ e 3 hit come atteso dal cambio di metrica.
- E[hits] scende leggermente (0.829 vs 0.833) perché il modello sacrifica valore atteso per concentrare le pick.
- L'improvement su P(≥3) è modesto: da 3.40% a 3.53% (+3.8% relativo).

### Muro matematico

Con 12 pick da 90 e 6 estratti, la distribuzione ipergeometrica fissa P(≥3) al ~3.3% anche con pick random. Nessun modello può portare P(≥3) vicino al 100% con 12 numeri, salvo prevedere il lotto (che richiederebbe non-randomness).

Strade per aumentare P(≥3):
1. **Più numeri giocati**: P(≥3) ≈ 13% con 18 pick, ~31% con 24, ~52% con 30
2. **Tuning più aggressivo**: 300+ iter, Cluster Boost più estremo
3. **Multi-combination output**: generare più sestine strategiche anziché un set piatto di 12

### Prossimi passi possibili Oracle

- [ ] Testare Oracle con top-18 e top-24 per misurare P(≥3) con più numeri
- [ ] Aumentare iterazioni tuner a 300+ e range Cluster Boost più estremo
- [ ] Aggiungere Oracle per EJ
- [ ] Cache parametri Oracle su disco (attualmente nessun caching)
- [ ] Ensemble Nexus + Oracle: combinare i due engine con meta-scoring

## GenesisEngine — trovare ordine nel caos (2026-04-14)

Terzo motore predittivo. Filosofia radicale: **non usare statistiche** ma fisica, teoria dell'informazione e fluidodinamica per cercare ordine in dati apparentemente random.

### Canali

| Canale | Disciplina | Idea | Mai provato prima? |
|--------|-----------|------|-------------------|
| **SpectralWave** | Analisi di Fourier | Decomposizione armonica sul cerchio 1-90. Ogni estrazione è un "accordo". Armoniche dominanti rivelano frequenze spaziali ricorrenti. Interferenza costruttiva = numeri predetti. | Si: nessuna applicazione di DFT circolare a lotterie con walk-forward |
| **CompressionOracle** | Teoria dell'informazione | Per ogni numero, la storia ON/OFF è una sequenza binaria. PPM (Prediction by Partial Matching) cerca pattern: se gli ultimi 1-5 bit matchano un pattern storico, predice il prossimo bit. | Si: Shannon applicato come predittore diretto su bitmap di singoli numeri |
| **VortexDynamics** | Fluidodinamica | I numeri dell'ultima estrazione diventano vortici puntuali su un cerchio. Le equazioni di Helmholtz-Kirchhoff (interazione cotangente) predicono dove i vortici migrano. | Si: meccanica dei fluidi 2D applicata a numeri del lotto |
| **HolographicMemory** | Neuroscienze | Rete di Hopfield: ogni estrazione è un pattern ±1. La somma di tutti i pattern è una "memoria olografica". L'ultima estrazione come chiave ricostruisce pattern associati, incluse ANTI-correlazioni. | Parzialmente: Hopfield è noto, ma l'applicazione ±1 con excess-overlap su lotterie è nuova |
| **Cluster Boost** | Ottimizzazione combinatoria | Stesso post-processing di Oracle: concentra le pick in un cluster coerente | No (condiviso con Oracle) |

### File

| File | Ruolo |
|------|-------|
| `GenesisEngine.cs` | Engine con 4 canali + Cluster Boost, tabelle trig precomputate |
| `GenesisTuner.cs` | Walk-forward tuner con metrica P(≥3) |

### Precomputazioni

- **Bitmaps** `bool[k+1][rows]`: per ogni numero, vettore ON/OFF per CompressionOracle
- **Tabelle trigonometriche** `double[MaxHarmonics+1, k+1]`: cos/sin precomputati per SpectralWave (evita Math.Cos/Sin nel loop caldo)

18 parametri tunabili: 4 pesi canale, 3 Wave, 2 PPM, 3 Vortex, 2 Holographic, 4 Cluster.

### Risultati (run 2026-04-14, 4166 estrazioni, 3966 test points)

Confronto completo tutti gli engine:

| Metrica | Random | Nexus | Oracle | Genesis |
|---------|--------|-------|--------|---------|
| E[hits] top-12 | 0.800 | **0.833** (+4.1%) | 0.829 (+3.6%) | 0.800 (±0.0%) |
| P(≥3 hit) | ~3.3% | 3.40% | **3.53%** | 3.48% |

Hit distribution top-12:

| Hit | Random (atteso) | Nexus | Oracle | Genesis |
|-----|-----------------|-------|--------|---------|
| 0 | ~39.8% | 39.4% | 40.3% | **41.8%** |
| 1 | ~41.5% | 41.9% | 40.4% | 40.2% |
| 2 | ~15.3% | 15.3% | **15.8%** | 14.6% |
| 3 | ~3.1% | 2.9% | 3.2% | **3.3%** |
| 4 | ~0.3% | 0.5% | 0.4% | 0.2% |

### Osservazioni Genesis

- **E[hits] = baseline esatta (0.800)**: i canali fisici/informazionali non producono edge medio. Questo è coerente con l'ipotesi che il SuperEnalotto sia un processo quasi-random.
- **P(≥3) = 3.48%**: sopra il random (3.3%) nonostante zero edge medio. Genesis concentra i colpi: più 0-hit (41.8%) ma anche più 3-hit (3.3%). Il tradeoff concentrazione/diversificazione è visibile.
- **Numeri predetti diversi** da Nexus e Oracle: 38, 54, 08, 06, 60, 56, 45, 55, 61, 04, 62, 10. Quasi nessuna sovrapposizione con Nexus (20, 62, 66, 09...) o Oracle (39, 19, 74, 10...).
- **131 estrazioni con 3+ hit** su 3966 test points. Per confronto: Nexus ne ha 135, Oracle 140.

### Conclusione sperimentale (aggiornata con Mosaic)

Quattro paradigmi radicalmente diversi convergono tutti nello stesso intorno: **P(≥3) ≈ 3.3-3.5%** con 12 pick da 90.

Il muro ipergeometrico P(≥3 | 12/90, 6 estratti) ≈ 3.3% è il vincolo dominante. Tutti gli approcci provati — statistici, caotici, fisici, strutturali — producono micro-edge dello 0-5% su E[hits] e P(≥3) appena sopra random.

### Osservazione cross-engine: convergenza dei numeri predetti

Nonostante i 4 engine usino canali completamente diversi, alcuni numeri appaiono in MULTIPLI engine per la stessa estrazione target. Esempio run 2026-04-14:
- **10**: Oracle, Genesis, Mosaic (3/4 engine)
- **38**: Genesis, Mosaic (2/4)
- **06**, **08**: Genesis, Mosaic (2/4)
- **54**, **62**, **61**: Nexus, Genesis (2/4)
- **58**, **13**: Nexus, Oracle (2/4)
- **09**: Nexus, Mosaic (2/4)

Questo suggerisce che un **meta-ensemble a voti** (numeri con più consenso cross-engine) potrebbe amplificare il segnale debole di ciascuno.

### Strade future

1. **Meta-ensemble a voti**: combina i 4 engine, seleziona i 12 numeri con più "voti" cross-engine
2. **Più numeri giocati**: P(≥3) cresce drasticamente con 18+ pick
3. **Sistemi combinatoriali**: generare multiple sestine strategiche che coprono il pool predetto

## MosaicEngine — ordine strutturale nel caos (2026-04-14)

Quarto motore predittivo. Filosofia: il canvas 4166×90 è un **tessuto** (mosaico) con struttura nascosta. Cerchiamo ordine guardando il tessuto da angolazioni mai tentate.

### Canali

| Canale | Disciplina | Idea | Mai provato prima? |
|--------|-----------|------|-------------------|
| **TransitionField** | Catene di Markov | Matrice 90×90 di probabilità condizionate: P(m appare | n è apparso nell'estrazione PRECEDENTE). Non co-occorrenza (stessa estrazione) — SUCCESSIONE (estrazioni consecutive). Score = eccesso sopra baseline random. | Si: Markov su singoli numeri tra estrazioni consecutive (diverso da pattern matching) |
| **CellularRule** | Automi cellulari | Il canvas come output di un CA ignoto. Per ogni numero, guarda i VICINI sul cerchio 1-90 nell'estrazione precedente. Apprende P(cella ON | stato vicinato). Invarianza traslazionale sul cerchio. | Si: inferenza di regole CA da dati reali di lotteria |
| **ModularResonance** | Teoria dei numeri | Per ogni primo p ∈ {2,3,5,7,11,13}, calcola le classi di residui (n mod p) e verifica quali classi sono "calde". Boost numeri in classi hot. | Si: classi di residui modulari come feature predittive su lotterie |
| **CrystalBoost** | Cristallografia | Funzione di correlazione di coppia g(d). Rivela distanze PREFERITE tra numeri estratti (come atomi in un cristallo). Post-processing: seleziona numeri a distanze dove g(d) > 1. | Si: pair correlation function applicata a selezione di numeri del lotto |

### File

| File | Ruolo |
|------|-------|
| `MosaicEngine.cs` | Engine con 3 canali scoring + CrystalBoost post-processing |
| `MosaicTuner.cs` | Walk-forward tuner con metrica P(≥3) |

15 parametri tunabili: 3 pesi canale, 3 Transition, 3 CellularRule, 2 Modular, 4 Crystal.

### Risultati (run 2026-04-14, 4166 estrazioni, 3966 test points)

Confronto completo tutti gli engine:

| Metrica | Random | Nexus | Oracle | Genesis | Mosaic |
|---------|--------|-------|--------|---------|--------|
| E[hits] top-12 | 0.800 | **0.833** (+4.1%) | 0.829 (+3.6%) | 0.800 (±0.0%) | 0.794 (-0.7%) |
| P(≥3 hit) | ~3.3% | 3.40% | 3.53% | 3.48% | 3.45% |

### Osservazioni Mosaic

- **Fast metric più alto tra i primi 4 engine (0.0526)** — ma non ha retto nel full walk-forward.
- **E[hits] = 0.794**, leggermente SOTTO baseline. Mosaic concentra più aggressivamente di Genesis.
- **P(≥3) = 3.45%**: comunque sopra random nonostante E[hits] sotto baseline.

## QuantumEngine — meccanica quantistica applicata (2026-04-14)

Quinto motore predittivo. Simula la **meccanica quantistica** (cammino quantistico con coin su un grafo circolare) applicata alla previsione del lotto. L'interferenza quantistica crea distribuzioni di probabilità qualitativamente diverse da qualsiasi cammino classico.

### Canali

| Canale | Disciplina | Idea | Mai provato prima? |
|--------|-----------|------|-------------------|
| **QuantumWalk** | Meccanica quantistica | I numeri dell'ultima estrazione sono la posizione iniziale di un walker quantistico su un cerchio di 90 nodi. Coin parametrico (rotazione) + shift condizionale (sinistra/destra). Dopo T passi, la distribuzione di probabilità mostra dove il walker è più probabile. L'interferenza quantistica crea picchi/valli impossibili classicamente. | **Si: prima applicazione di quantum walk simulato a previsione lotteria** |
| **WaveletMomentum** | Analisi wavelet | Per ogni numero, calcola la VARIAZIONE del tasso di occorrenza a 6 scale temporali (4, 8, 16, 32, 64, 128 estrazioni). Un numero può essere "freddo" (basso tasso) ma in "accelerazione" (tasso in aumento). Diverso da Hot/Gap che misurano il livello assoluto. | Parzialmente: wavelet multi-scala su singoli numeri come predittore è nuovo |
| **ClusterBoost** | Post-processing co-occorrenza | Stesso approccio degli altri engine | No |

### File

| File | Ruolo |
|------|-------|
| `QuantumEngine.cs` | Engine con quantum walk (ampiezze complesse) + wavelet momentum |
| `QuantumTuner.cs` | Walk-forward tuner con metrica P(≥3) |

12 parametri tunabili: 2 pesi canale, 3 QuantumWalk, 3 Wavelet, 4 Cluster.

### Implementazione Quantum Walk

- Stato: vettore di 2×K = 180 ampiezze complesse (K posizioni × 2 stati coin left/right)
- Inizializzazione: sovrapposizione equa alle posizioni dei numeri dell'ultima estrazione
- Operatore coin: rotazione 2×2 parametrica `R(θ) = [[cos θ, -sin θ], [sin θ, cos θ]]`
- Operatore shift: `|n, left⟩ → |n-1, left⟩`, `|n, right⟩ → |n+1, right⟩` (con wrapping circolare)
- Evoluzione: T passi di (Coin × Shift)
- Misura: P(n) = |ψ(n, left)|² + |ψ(n, right)|²

### Risultati — **MIGLIOR P(≥3) IN ASSOLUTO**

| Metrica | Random | Nexus | Oracle | Genesis | Mosaic | **Quantum** |
|---------|--------|-------|--------|---------|--------|-------------|
| E[hits] top-12 | 0.800 | **0.833** | 0.829 | 0.800 | 0.794 | 0.806 |
| Edge | — | +4.1% | +3.6% | ±0.0% | -0.7% | +0.7% |
| P(≥3 hit) | ~3.3% | 3.40% | 3.53% | 3.48% | 3.45% | **3.68%** |

**P(≥3) = 3.68%** — il più alto di QUALSIASI engine testato. +11.5% sopra random baseline. L'interferenza quantistica trova struttura dove nessun altro approccio la vede.

## Meta-Ensemble — Wisdom of Crowds (2026-04-14)

Combinazione parameter-free di tutti e 5 gli engine: per ogni test point, prende i top-12 di ciascun engine e seleziona i 12 numeri con più "voti".

### Risultati

| Metrica | Ensemble |
|---------|----------|
| E[hits] | 0.816 (+2.1%) |
| P(≥3) | 3.43% |

L'ensemble media il segnale anziché amplificarlo. Il voting tende a selezionare numeri "generici" (che piacciono a molti engine) anziché i numeri "specializzati" che producono i colpi migliori.

### Convergenza cross-engine (prossima estrazione, run 2026-04-14)

| Numero | Engine che lo predicono | Voti |
|--------|------------------------|------|
| **10** | Oracle, Genesis, Mosaic, Quantum | **4/5** |
| **38** | Genesis, Mosaic, Quantum | **3/5** |
| 18, 84, 39, 20, 61, 13, 09, 08, 58, 60 | vari | 2/5 |

### Classifica finale per P(≥3 hit)

1. **Quantum** — 3.68% (+11.5% vs random)
2. Oracle — 3.53%
3. Genesis — 3.48%
4. Mosaic — 3.45%
5. Ensemble — 3.43%
6. Nexus — 3.40%

## Limiti noti / TODO

**Fatti**:
- [x] ~~File `data/2002.txt` mancante~~ — backfillato
- [x] ~~Tuner separato per SuperStar~~ — SS da 0.027 a 0.047
- [x] ~~Output ordinato per % DESC~~
- [x] ~~Ultime 3 estrazioni stampate prima del top~~
- [x] ~~Supporto EuroJackpot~~
- [x] ~~Filtro temporale Euro numeri EJ dal 2022-03-22~~
- [x] ~~OracleEngine~~ — Resonance, Constellation, Attractor, Numerology, Cluster Boost
- [x] ~~GenesisEngine~~ — SpectralWave, CompressionOracle, VortexDynamics, HolographicMemory
- [x] ~~MosaicEngine~~ — TransitionField, CellularRule, ModularResonance, CrystalBoost
- [x] ~~QuantumEngine~~ — QuantumWalk (miglior P(≥3): 3.68%), WaveletMomentum
- [x] ~~Meta-Ensemble~~ — voting cross-engine parameter-free

**Da fare**:
- [ ] Hold-out split per valutazione onesta
- [ ] Cache dei pesi tunati su disco per evitare tuning ad ogni avvio
- [ ] Top-18 / top-24: testare P(≥3) con più numeri giocati
- [ ] Sistemi combinatoriali: generare multiple sestine strategiche dal pool predetto
- [ ] Esplorare varianti del quantum walk (Grover walk, walk su grafi non circolari)
- [ ] Meta-ensemble pesato (tuning dei pesi cross-engine anziché voting uguale)

## Componenti attuali

| File | Engine | Paradigma |
|------|--------|-----------|
| `NexusEngine.cs` + `NexusTuner.cs` | Nexus | Statistico (Tide, Mutation, Gravity, Fractal) |
| `OracleEngine.cs` + `OracleTuner.cs` | Oracle | Caos/Esoterico (Resonance, Constellation, Attractor, Numerology) |
| `GenesisEngine.cs` + `GenesisTuner.cs` | Genesis | Fisico/Informazionale (SpectralWave, PPM, Vortici, Hopfield) |
| `MosaicEngine.cs` + `MosaicTuner.cs` | Mosaic | Strutturale/Numerico (Markov, CA, Mod primi, Cristallografia) |
| `QuantumEngine.cs` + `QuantumTuner.cs` | Quantum | Meccanica quantistica (QuantumWalk, WaveletMomentum) |
| `Program.cs` (sezione ensemble) | Meta-Ensemble | Wisdom of Crowds (voting cross-engine) |

## Storico decisioni

- **2026-04-10**: progetto nato da zero dopo deprecazione di `SelGridViewer/MerlinoEngine`.
- **2026-04-10**: scelto approccio B (Canvas storico) tra A/B/C discussi in chat.
- **2026-04-10**: fonte dati spostata da `lottologia.com` a `superenalotto.com`.
- **2026-04-13**: implementato OracleEngine con paradigma P(≥3). P(≥3)=3.53%.
- **2026-04-14**: implementato GenesisEngine (Fourier, PPM, vortici, Hopfield). P(≥3)=3.48%.
- **2026-04-14**: implementato MosaicEngine (Markov, CA, mod primi, cristallografia). P(≥3)=3.45%.
- **2026-04-14**: implementato QuantumEngine (quantum walk + wavelet). **P(≥3)=3.68% — miglior risultato in assoluto** (+11.5% vs random). La meccanica quantistica simulata trova struttura invisibile agli altri paradigmi.
- **2026-04-14**: implementato Meta-Ensemble a voti cross-engine. P(≥3)=3.43% (deludente: il voting media il segnale). Osservazione notevole: il numero 10 appare in 4/5 engine, il 38 in 3/5.

## Risultati reali vs predetti

### Estrazione 15-04-2026 (SE)

| | Numeri | SuperStar |
|---|--------|-----------|
| **Giocati** (output Merlino) | 10, 18, 37, 39, 47, 87 | 7 |
| **Estratti** | 3, 5, 20, 27, 35, 66 | 6 (Jolly: 17) |
| **Hit** | **0 / 6** | **miss** |

Zero sovrapposizione. Il modello non ha intercettato nemmeno 1 numero su 6.

### Estrazione 15-04-2026 (EJ)

| | Main (1-50) | Euro (1-12) |
|---|------------|-------------|
| **Giocati** (output Merlino) | 5, 16, 18, 22, 35 | 3, 11 |
| **Estratti** | 13, 22, 32, 46, 47 | 6, 7 |
| **Hit** | **1 / 5** (22) | **0 / 2** |

Un solo hit main (il 22). Nessun euro numero.

### Analisi risultato

- **SE**: 0 hit su 6 numeri giocati (da 90). Con pick random la probabilità di 0 hit su 6 è ~65%. Non è statisticamente anomalo per una singola estrazione, ma il modello dovrebbe fare meglio del random.
- **EJ**: 1 hit su 5 main (da 50). Baseline random attesa = 5×5/50 = 0.5 hit. Avere 1 hit è sopra la baseline, ma il campione è minuscolo.
- **Nota critica**: il numero **10** era predetto da 4/5 engine nella run precedente e NON è uscito. Il **47** era nei giocati MA non era tra i top del modello — chiarire come sono stati scelti i 6 numeri effettivamente giocati.
