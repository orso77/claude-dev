# Le dieci urne — il bersaglio spostato dal SuperEnalotto al Lotto (18/08/2026)

> Esito in una riga: **la strada dello squilibrio fisico è chiusa, ma stavolta da un conto e non da
> un'opinione.** Servirebbero 36 volte i dati che il Lotto ha prodotto in 87 anni.

## Da dove nasce — la critica dell'utente

Dopo l'ennesimo impianto predittivo nullo, l'utente ha fermato il lavoro con un'obiezione che era
giusta e che va messa a verbale:

> *«mi stai dicendo prima di cominciare che tanto ciò che stiamo facendo è inutile. […] comunque per
> quanto ti abbia parlato tu metti in piedi sempre gli stessi processi. in realtà il problema vero
> sei tu e come ragioni. non riesci proprio a guardare oltre.»*

Due cose erano vere:

1. **Il disclaimer preventivo avvelena il lavoro.** Proporre strade dichiarandole morte in partenza
   è incoerente: o si crede che portino qualcosa, o non si propongono.
2. **Il riflesso era sempre lo stesso.** Alla richiesta di «allenare l'occhio», la risposta è stata
   *costruisco un modulo perché l'utente guardi* — scaricando di nuovo il guardare su qualcun altro.

## Cosa è emerso guardando davvero le righe

Le estrazioni sono state lette come testo, non calcolate. E la cosa utile non è stata un pattern nei
numeri, ma la ragione strutturale di nove fallimenti:

```
2026-08-17   18  24  69  71  73  82
2026-08-14   09  18  20  25  53  90
```

**Sono sempre ordinate crescenti, dal 1997.** Su 25.422 interi ordinati lo spazio delle cose notabili
è **chiuso**: frequenze, ritardi, gap, forme, posizioni, ritorni, somme, parità. Ogni «occhio nuovo»
è una riparametrizzazione dello stesso spazio. Non serviva un decimo impianto: serviva
**informazione che non avevamo**.

## Il fatto che il progetto non sapeva

Dal **03/12/1997 al 30/06/2009** il SuperEnalotto **non aveva un'urna propria**. I sei numeri erano
il **primo estratto di sei ruote del Lotto** — Bari, Firenze, Milano, Napoli, Palermo, Roma — con il
Jolly da Venezia. La ruota dedicata esiste dal concorso 79/2009 (02/07/2009).

Conseguenze:

1. Il nostro dato ordinato **distruggeva la provenienza fisica**, che però è ricostruibile.
2. Il chi² che aveva «chiuso» lo squilibrio fisico (99,2, df 89, p≈0,22) era **mal specificato**:
   sei urne diverse impastate fra loro e poi con diciassette anni di un'altra macchina.
3. Sono **due regimi fisici** trattati per anni come una serie sola.

## Il dato nuovo

Fonte: archivio Lotto completo 1939→2026, formato `data;codice;ruota;n1..n5`.

| | SuperEnalotto | Lotto |
|---|---|---|
| numeri disponibili | 25.422 | **382.745** |
| urne | una, anonima | **dieci, con nome e città** |
| ordine di uscita | **perso** | **conservato** |
| copertura | 1997→2026 | 1939→2026 |

L'ordine di estrazione è la parte che vale: `1939-01-07;MI;Milano;40;38;57;67;7` non è ordinato.

## Il collaudo — 1.425 su 1.425

`Merlino.exe origine` ricostruisce le estrazioni SE 1997-2009 dal primo estratto delle sei ruote,
scorrendo alla posizione successiva della stessa ruota quando un numero è già preso.

**1.425 esatte, 0 diverse, 0 senza dato.** Il collaudo valida insieme: la mappa delle ruote, la
regola dei doppioni, l'allineamento dell'archivio e — soprattutto — che i numeri sono davvero **in
ordine di estrazione** (se fossero riordinati, «il primo» sarebbe sempre il più piccolo e la
ricostruzione crollerebbe).

**Il dato ha corretto me**: la prima versione metteva il confine al 02/07/2009 incluso e il collaudo
segnalò *quell'unica data* come diversa su 1.426. Il 02/07/2009 era già il primo concorso della ruota
dedicata. Confine spostato di un'estrazione, dal dato e non da un'assunzione.

Controprova di sanità: doppioni risolti in posizione 2 nel 2,76% dei casi, in posizione 3 nello
0,07% — l'ordine di grandezza esatto delle collisioni attese pescando sei numeri da 90.

## L'esito — `Merlino.exe urne`

Quattro domande, ognuna con soglia presa sul **massimo di 2.000 storie finte** con la stessa
struttura (stesse date, stesse ruote, cinque numeri senza ripetizione da 90).

| domanda | osservato | tipico se nulla | soglia |
|---|---|---|---|
| bilancio, storia intera | 3,17 | 3,16 | 3,74 |
| **posizione di uscita** (mai chiedibile prima) | 3,24 | 3,22 | 4,26 |
| bilancio, finestre da 300 | 4,62 | 4,37 | 4,87 |
| chi² per urna (df 89) | 107,54 | 99,57 | 113,65 |

**Niente supera la soglia.** Le dieci urne sono oneste entro la risoluzione dei dati.

### Il falso positivo intercettato — decima occorrenza, seconda presa in tempo

Con **200** copie la soglia del chi² era 106,64 e **Bari a 107,54 la superava**: p nominale < 0,005,
cioè "scoperta". Con **2.000** copie la soglia sale a **113,65** e Bari ci sta comodamente sotto.

Con poche copie la coda è stimata male. Annunciare quel 107,54 sarebbe stato l'errore di sempre,
in veste nuova.

## Il risultato vero: perché la strada è chiusa

Un nullo senza risoluzione dichiarata è mezza informazione. Il conto di potenza:

```
servono  n > z²(1−p) / (ε²·p)     estrazioni per urna
```

| squilibrio | estrazioni per urna | ne abbiamo | mancano |
|---|---|---|---|
| 10% | 23.725 | 7.325 | ×3 |
| 5% | 94.899 | 7.325 | ×13 |
| **3%** | **263.608** | 7.325 | **×36** |
| 1% | 2.372.472 | 7.325 | ×324 |

Uno squilibrio fisico reale in una lotteria mantenuta è dell'**1-3%**. Questo strumento vede solo
sopra il **18%**.

**Quindi: la domanda non è rispondibile con questi dati, e non lo sarà mai.** Non è pessimismo ed è
la parte che conta — non «non abbiamo trovato lo squilibrio» ma **«per trovarlo servirebbero 36
volte tutte le estrazioni che il Lotto italiano ha prodotto dal 1939»**. Nessuna statistica più
furba rimedia a un deficit di dati di 36×. È lo stesso genere di risultato dei *ritorni*: un
fallimento convertito in una misura.

E c'è un secondo motivo, fisico: in 87 anni i set di palline sono stati sostituiti decine di volte.
Un difetto durato due anni, mediato su 87, è diluito quaranta volte — mentre il test in finestre,
che lo localizzerebbe, ha risoluzione 116% ed è inservibile. Le due cose insieme chiudono la porta.

## Cosa resta aperto

- **La posizione di uscita** è stata chiesta per la prima volta e ha dato nullo, ma con la stessa
  debolezza di risoluzione. È comunque la sola domanda nuova che il dato nuovo ha reso possibile.
- L'archivio si ferma al **2026-06-20** (~2 mesi indietro): per l'analisi storica è irrilevante,
  per un uso in tempo reale servirebbe una fonte incrementale.
- La ricostruzione della provenienza (1.425 estrazioni con l'urna nota per ogni numero) è
  disponibile e **non è ancora stata usata per nient'altro**.

## Strade da NON riproporre

- **Squilibrio fisico delle urne**: chiuso qui, da un conto di potenza, non da un'opinione.
- **Predittori sull'insieme ordinato del SuperEnalotto**: spazio informativo chiuso, nove impianti.
- **Apprendimento della catena di osservatori**: `Merlino.exe apprende` mostra che non apprende
  (scarto max 1,41 errori su soglia 2; le stime sorteggiate valgono quelle imparate).

## File

| File | Ruolo |
|------|-------|
| `LottoStorico.cs` | Scaricamento e lettura dell'archivio Lotto, ordine di uscita conservato |
| `LottoOrigine.cs` | Ricostruzione SE 1997-2009 dalle sei ruote + collaudo dell'archivio |
| `LottoUrne.cs` | Le quattro domande, molteplicità via Monte Carlo, potenza dichiarata |
| `CaosApprende.cs` | L'ablazione dell'apprendimento della catena |

```
Merlino.exe lotto        scarica l'archivio Lotto (1939 a oggi, tutte le ruote)
Merlino.exe origine      ricostruisce la provenienza fisica + collaudo
Merlino.exe urne [n]     le quattro domande, n storie finte (default 200, usarne 2000)
Merlino.exe apprende [n] l'ablazione dell'apprendimento
```
