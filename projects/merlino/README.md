# Merlino

> **Ripartenza da zero — 17/08/2026.** Tutti gli algoritmi costruiti fino a questa data sono
> **deprecati** (non funzionano) e con essi **tutto il metro di misura** che li accompagnava
> (distribuzione nulla, p-value, sigma, hold-out, walk-forward metrico, canali di controllo a
> rumore). Restano sul disco e compilano, ma sono fuori dal percorso dell'applicazione.
> Tutto ciò che in questo file sta sotto la riga «ARCHIVIO STORICO» descrive lavoro deprecato.

**Un solo modello attivo: la griglia grafica.** Analisi completa:
[griglia-grafica-analisi.md](griglia-grafica-analisi.md).

## Il modello

I numeri stanno su una **tela** (`GrigliaLayout`): può essere un rettangolo di qualsiasi formato, ma
anche un triangolo, una piramide, un rombo, un esagono, un cerchio, una croce, una spirale o una
curva di Hilbert. Ogni estrazione accende le sue celle e **disegna una figura**. Il modello guarda le
figure disegnate dal 1997 a oggi e ne disegna una nuova per la prossima estrazione.

La disposizione usata per la giocata è la **schedina 9×10** — non perché sia la migliore (nessuna lo
è, vedi sotto) ma perché è quella che si ha sotto gli occhi giocando.

**Zero matematica, zero statistica**: nessuna frequenza, nessun ritardo, nessuna probabilità,
nessuna calibrazione, nessun peso tarato, nessun parametro libero. Ogni canale è un'operazione di
**disegno** e restituisce un'**immagine** della griglia. Le immagini si sovrappongono come lucidi;
le celle più luminose sono la giocata.

### I dieci canali

| Canale | Operazione grafica |
|---|---|
| **Eco di forma** | La figura di adesso ha una sagoma. Si cercano nello storico le figure con la stessa sagoma — anche riflessa o capovolta — e si **ridisegna il loro seguito**, traslato quanto serve per portare la sagoma di allora sopra quella di adesso. |
| **Scia** | Da un'estrazione all'altra le celle si spostano. Ogni cella si aggancia alla più vicina della precedente: quello è il suo passo. La scia prosegue di un altro passo. |
| **Calco** | Le ultime 5 estrazioni sovrapposte formano un quadro. Si fa scorrere lo stesso quadro su tutto lo storico, si tengono i momenti in cui il disegno si somigliava di più, e si ridisegna l'estrazione che venne subito dopo. |
| **Specchio** | La griglia ha tre simmetrie che la mandano in sé stessa (sinistra-destra, alto-basso, mezzo giro). Ogni cella accesa di recente accende i propri riflessi. |
| **Crescita** | La figura si allarga sul bordo: attorno a ogni cella accesa si accendono le confinanti, più forte quelle di lato che quelle in diagonale. |
| **Retta** | Due celle allineate (riga, colonna o diagonale a 45°) individuano un tratto. Il tratto si prolunga oltre l'estremo. |
| **Analogia** | *A sta a B come C sta a X.* Trovata una figura A somigliante, guarda **come** A si trasformò in B — di quanto si mosse ogni punto — e applica quello stesso cambiamento alla figura di adesso. Non copia il risultato di allora: copia il gesto che lo produsse. |
| **Gesto** | Il disegno come **scrittura a mano**: la penna passa per le celle in un ordine canonico e la sequenza dei tratti è la sua *grafia*. Si ritrova la grafia nello storico e si continua a scrivere dal punto in cui la penna si è fermata. |
| **Piega** | Il foglio come **lenzuolo elastico**: i sei spostamenti fra le ultime due figure sono i campioni di una piega interpolata su tutta la tela, e l'intero quadro scivola nel verso in cui già stava scivolando. |
| **Contorno** | Il disegno come **area** e non come punti: il guscio convesso riempito. Due estrazioni possono avere zero celle in comune e occupare la stessa area con la stessa forma. |

I primi sei sono i costrutti iniziali; gli ultimi quattro sono stati inventati il 17/08/2026 su
richiesta esplicita («crea tu un algoritmo grafico»). Sono i migliori mai costruiti — alzano la
sensibilità dello strumento su tutta la scala del segnale finto — e sui dati veri segnano 1,00 come
tutti gli altri.

**Anti-leakage**: per disegnare l'estrazione `t` si guardano solo le righe `[0, t)`. Le somiglianze
storiche si fermano a `t-2`, così il loro seguito è al massimo `t-1`.

### Ritaglio al mezzo tono

Prima di sovrapporre, ogni lucido viene **ritagliato alla propria macchia**: sotto il mezzo tono si
cancella. Senza questo passaggio ogni canale contribuisce anche con la propria sfumatura di fondo,
la sovrapposizione tinge mezza griglia e diventa impossibile dire se una macchia è finita su un
numero per davvero. È la differenza fra 14 celle calde su 90 e più di 40.

## L'unica verifica ammessa

Il modello vede tutto lo storico **tranne l'ultima estrazione**, disegna le macchie calde, e sopra
il disegno si scrivono i numeri **realmente usciti**. Se le macchie ci cadono sopra, funziona.

Nessuna metrica, nessuna media, nessuna baseline, nessun p-value, nessun confronto col rumore: si
guarda il disegno. La stessa verifica viene ripetuta all'indietro sulle ultime 12 estrazioni, ognuna
prevista da tutto ciò che la precede.

## Esito della verifica (run 17/08/2026)

Estrazione del **14/08/2026** (`09 18 20 25 53 90`), modello costruito sulle prime 4.236 estrazioni:

| Numero uscito | Cella dove è caduto |
|---|---|
| 25 | tiepida |
| 09 | appena tiepida |
| 18, 20, 53, 90 | **spente** |

Il disegno teneva calde **14 celle su 90**. Quattro numeri su sei sono caduti nel vuoto.
Sulle 12 estrazioni all'indietro il quadro è lo stesso: la maggior parte dei numeri usciti cade su
celle spente, e i pochi centri su macchia calda non si distinguono da coincidenze.

**Il modello grafico, misurato col criterio richiesto, non mette le macchie dove escono i numeri.**

Va segnalato che la prima versione — senza il ritaglio al mezzo tono — *sembrava* funzionare
(`o : : O : .` sui sei numeri): ma teneva calda quasi metà griglia, quindi cadere dentro una macchia
non voleva dire niente. È lo stesso errore già commesso otto volte in questo progetto, in forma
grafica anziché numerica: un criterio che non può fallire non è una verifica.

## Il confronto di tutte le forme (17/08/2026)

**177 disposizioni provate** — 103 per il SuperEnalotto, 74 per l'EuroJackpot: tutti i formati di
rettangolo (per righe, a serpentina, per colonne), triangoli, piramidi, rombo, esagoni, cerchi,
croci, spirali, diagonali, mattoni, scacchiere, curva di Hilbert, curva Z, **e 30 permutazioni
completamente casuali** come paragone.

Criterio: **COLPI** (numeri usciti caduti dentro una macchia) diviso **MACCHIA** (quanta tela il
disegno tiene calda) = **GUADAGNO**. 1,00 = le macchie prendono esattamente quello che prenderebbero
per la loro sola estensione, cioè zero informazione. Blocco di scelta 1.900 estrazioni, blocco di
conferma le 1.900 più recenti, mai usate per scegliere.

**Prima lo strumento è stato tarato** su storici finti a segnale grafico noto (`Merlino.exe prova`):

| Palline a caso su 6 | 0 | 1 | 2 | 3 | 4 | 5 | 6 |
|---|---|---|---|---|---|---|---|
| Guadagno | 13,79 | 6,53 | 5,20 | 4,29 | 2,92 | 2,02 | 1,02 |

Basta **una sola pallina su sei** che segua una regola grafica perché il guadagno raddoppi. Lo
strumento vede benissimo.

### Esito: la forma non conta

| | SuperEnalotto | EuroJackpot |
|---|---|---|
| Miglior forma costruita | Scacchiera larga **1,037** → conferma 0,996 | Scacchiera rada **1,063** → conferma 0,947 |
| **Miglior disposizione a caso** | **A CASO #5 1,050** → conferma 1,016 | **A CASO #1 1,129** → conferma 0,914 |
| Mediana costruite / a caso | 0,991 / 0,993 | 0,988 / 1,018 |
| Costruite sopra la migliore a caso | **0 su 73** | **0 su 44** |

In entrambi i giochi **la disposizione migliore è una permutazione casuale**, nessuna forma
costruita la supera, e le mediane coincidono. Tutte le 177 disposizioni stanno attorno a 1,00.

Triangolo, piramide, rombo, esagono, cerchio, croce, spirale, Hilbert, scacchiera, serpentina, ogni
formato di rettangolo, la schedina classica e una permutazione a caso: **tutte uguali, tutte a zero
informazione**. Con lo strumento che segna 2,02 per una sola pallina su sei, nelle estrazioni reali
**non c'è nemmeno un sesto di pallina di segnale grafico, in nessuna disposizione**.

La posizione di un numero su una griglia è una convenzione tipografica, non una proprietà dell'urna.

## Il banco di prova — scelta del sistema (17/08/2026)

`Merlino.exe test`. Ogni configurazione **ricammina tutta la storia** predicendo ogni estrazione da
ciò che la precede. Blocco di scelta 1.900 estrazioni, blocco di conferma le 1.900 più recenti.

Provate: i **6 canali singoli**, tutte le **63 combinazioni** di canali, **17 varianti strutturali**
(tela a toro, sagome parziali/strette/identiche, finestra 2→15, somiglianze 4→200, taglio 0,30→0,85).
Più due famiglie di **controlli** e due **ancore** a segnale noto.

### Verdetto

| SuperEnalotto | |
|---|---|
| Miglior configurazione sui dati veri | **Specchio 1,045** → conferma 1,022 (11ª su 63) |
| la stessa su numeri messi **a caso** sulla tela | 0,914 .. **1,048** |
| la stessa con l'ordine del tempo **rimescolato** | 0,920 .. **1,069** |
| **Ancora**: 1 pallina su 6 con regola grafica | **4,651** → conferma **6,313**, **1ª su 63** |

| EuroJackpot | |
|---|---|
| Miglior configurazione sui dati veri | **Calco 1,096** → conferma 1,022 |
| la stessa con l'ordine del tempo **rimescolato** | 0,864 .. **1,112** |
| **Ancora**: 1 pallina su 5 con regola grafica | **3,078** → conferma **3,540**, **1ª su 63** |

**La configurazione migliore cade dentro le proprie bande di controllo.** Lo stesso modello, girato
su numeri messi a caso o su una storia con il tempo mescolato, arriva altrettanto in alto: non legge
nulla nei dati veri che non legga nel disordine. Le ancore chiudono dall'altro lato — bastava **una
pallina su sei** perché la ricerca la trovasse a 4,65 e la confermasse a 6,31.

Le due strade che restavano aperte sono state provate e non portano niente: **tela a toro** 0,975 e
**sagome parziali** 0,989, contro 0,980 di partenza.

### Con i quattro costrutti nuovi (10 canali, 1023 combinazioni)

La taratura dello strumento migliora su tutta la scala:

| Palline a caso su 6 | 0 | 1 | 2 | 3 | 4 | 5 | 6 |
|---|---|---|---|---|---|---|---|
| 6 canali | 13,79 | 6,53 | 5,20 | 4,29 | 2,92 | 2,02 | 1,02 |
| **10 canali** | **14,44** | **7,35** | **5,54** | **4,58** | **3,30** | **2,07** | 1,03 |

Il **Gesto** è il miglior canale singolo mai ottenuto: **1,081**. E l'**Analogia** da sola si piazza
terza su 1023 nel riconoscere un segnale grafico di una pallina su sei (4,045). Ma sui dati veri:

| | Valore |
|---|---|
| Gesto sul blocco di conferma | 1,022 — **164ª su 1023** |
| Gesto su numeri messi **a caso** sulla tela | 0,798 .. **1,112** |
| Gesto con l'ordine del tempo **rimescolato** | 0,874 .. **1,113** |
| **Ancora**: 1 pallina su 6 con regola grafica | **4,651**, **1ª su 1023** anche in conferma |

Lo stesso Gesto, girato su numeri messi a caso o su una storia col tempo mescolato, arriva **più in
alto** di quanto faccia sui dati veri.

**Non è il disegnatore a essere cieco: è il foglio a essere bianco.**

## Il difetto trovato guardando l'output (17/08/2026)

Segnalazione dell'utente su `18 19 20 22 27 29`: *«tutti e 6 sotto a 30, mi sembra molto
improbabile»*. Seconda volta che un'intuizione così scova un difetto vero.

`Merlino.exe scelte` non misura se il modello indovina, misura **dove guarda**. Risultato:

| riga | scelti dal modello | usciti davvero | neutro |
|---|---|---|---|
| 1-10 | **3,8%** | 11,0% | 11,1% |
| **41-50** | **20,8%** | 11,1% | 11,1% |
| 81-90 | **6,4%** | 11,8% | 11,1% |

Il **46** scelto nel 22,5% delle estrazioni, il **10** nell'1,4%: sedici volte tanto, fra numeri
equiprobabili. Il modello non preferiva i numeri bassi — **preferiva il centro del foglio**.

**Due cause, entrambe geometriche:**

1. **Perdita dei bordi.** I canali che traslano e prolungano buttavano via tutto ciò che finiva oltre
   il margine: una cella centrale riceve tratti da ogni direzione, una d'angolo solo da dentro.
   → **tela a toro accesa di default**: i bordi si ricongiungono, nessun tratto si perde.
2. **Il Contorno.** Il guscio convesso di sei punti sparsi sta addosso al centro molto più che ai
   margini (84,7% delle sue scelte nella fascia centrale contro 33,3% neutro). Non è raddrizzabile:
   usare il bordo invece dell'area piena dimezza il vizio ma su EJ resta al 97,6%.
   → **Contorno rimosso dalla configurazione di default.**

Siccome nessuna combinazione esce dalle bande di controllo, la scelta si è fatta sull'**equità**
(riga più servita ÷ riga meno servita; le estrazioni vere stanno a 1,11x):

| Combinazione | squilibrio |
|---|---|
| **senza Contorno** | **1,35x** |
| i sei originali | 1,42x |
| tutti e dieci | 2,49x |
| solo i quattro nuovi | 5,35x |

**Lezione**: un modello può essere inutile e storto insieme, e le due cose si misurano separatamente.
Il banco diceva 1,00 — «non predice niente», ed era giusto — ma un criterio che normalizza per
l'estensione della macchia è cieco a *dove* la macchia sta.

### Il sistema scelto

**Nove canali — tutti tranne il Contorno — tela a toro, schedina 9×10.**

1. Nessuna configurazione esce dalle proprie bande di controllo: la scelta non si può fare sulla
   prestazione, perché non c'è prestazione da confrontare.
2. Scegliere «solo Gesto» per quel 1,081 sarebbe l'errore che il banco serve a evitare — il suo
   stesso controllo arriva a 1,113, cioè lo batte.
3. A parità di resa si sceglie sull'equità geometrica: distribuzione risultante 10,2%–13,8% contro
   11,1% neutro, contro il 6,8%–16,8% di prima.

### Una scoperta sull'architettura

Il **Calco non è un canale grafico**: confronta i quadri con un prodotto cella per cella, e quella
somma non cambia se si rimescolano le etichette della tela. È invariante per permutazione — infatti
la sua banda di controllo su 24 disposizioni casuali è un punto solo (1,096 .. 1,096). Lavora sugli
insiemi di numeri, non sulle figure. Per lui l'unico controllo valido è il rimescolamento temporale.

## L'Occhio — il ragionamento dell'utente dentro l'algoritmo (17/08/2026)

Il ragionamento che ha trovato due difetti veri ha due tempi, e **solo il secondo vale**:

1. si nota qualcosa — *«tutti e sei sotto il 30…»*
2. si conclude *«mi sembra improbabile»* ← **questo sbaglia quasi sempre**, la sensazione di
   impossibilità segue la *descrivibilità*, non la probabilità

Ma qui non si guarda un'estrazione: si guarda **l'output di un modello**. La domanda giusta è
**«il modello lo fa più spesso di quanto capiti davvero?»** — ed è formalizzabile.

`GrigliaOcchio.cs` guarda dieci tratti (tutti nello stesso terzo, ampiezza stretta, consecutivi,
celle che si toccano, allineamenti, parità…) e per ognuno riporta: se la giocata ce l'ha, quanto
capita nelle estrazioni vere, quanto il modello lo produce. Gira **a ogni avvio**.

### Cosa ha trovato, e la correzione

| tratto | vere | modello prima | modello dopo |
|---|---|---|---|
| tutti nello stesso terzo | 0,2% | **1,5%** (6,4x) | 0,3% (1,4x) |
| ampiezza stretta | 1,5% | **7,7%** (5,0x) | 1,7% (1,1x) |
| tre o più consecutivi | 1,3% | **5,2%** (3,9x) | 1,3% (1,0x) |
| tre celle che si toccano | 16,2% | **43,4%** (2,7x) | ~1,0x |

Il modello disegna **macchie**, e prendere le sei celle più luminose vuol dire prendere sei punti
dello stesso fianco della stessa collina. Le estrazioni vere sono sei punti sparsi.

**Correzione — le vette**: soppressione dei non-massimi. Si prende la vetta, si abbassa il fianco
della collina, si prende la vetta successiva. Prima sovracorrezione (vietare le confinanti) presa
dall'occhio stesso: i consecutivi crollavano a 0,0% mentre un'estrazione su tre ne ha. Quindi
**attenuare, non vietare**: fattore 0,85, scelto con `Merlino.exe vette` che misura lo scostamento
di forma fra giocate del modello ed estrazioni vere (curva a U con minimo netto).

Non è taratura di resa — è taratura di **forma**: un modello di estrazioni deve produrre cose che
somigliano a estrazioni.

**Campo piatto**: `TaraCampo` misura quanta luce ogni cella riceve in media e ci divide ogni disegno,
come si corregge la vignettatura di un obiettivo. La riga centrale scende da 13,8% a 10,8% (neutro
11,1%). Sotto i 200 campioni non si applica: con pochi campioni il campo *è* rumore.

### Cosa questo NON cambia

**Niente di tutto questo migliora la resa.** Il modello continua a segnare 1,00, continua a non
predire niente, e la probabilità di vincere non cambia di un capello. Quello che è cambiato è che non
è più **storto**. Un modello inutile ma onesto è meglio di uno inutile e storto — il secondo fa
credere di vedere qualcosa.

## File del modello

| File | Ruolo |
|------|-------|
| `GrigliaLayout.cs` | Le disposizioni: rettangoli, triangoli, piramidi, rombo, esagoni, cerchi, croci, spirali, Hilbert, curva Z, mattoni, scacchiere, casuali |
| `GrigliaConfig.cs` | Le manopole di disegno: finestra, somiglianze, soglia sagoma, taglio, tela a toro, canali accesi |
| `GrigliaEngine.cs` | I sei canali, il ritaglio al mezzo tono, la sovrapposizione, il disegno a schermo |
| `GrigliaVerifica.cs` | L'unica verifica: macchie calde contro numeri realmente usciti |
| `GrigliaConfronto.cs` | Confronto di tutte le disposizioni, con blocco di scelta e blocco di conferma |
| `GrigliaProva.cs` | Storici finti a segnale noto + taratura dello strumento |
| `GrigliaTest.cs` | Il banco di prova: canali, combinazioni, varianti, controlli, ancore |
| `Program.cs` | Scaricamento → figure → verifica → giocata |

```
Merlino.exe            la giocata, con il sistema scelto
Merlino.exe test       il banco di prova completo (canali, combinazioni, varianti, controlli)
Merlino.exe forme      confronta TUTTE le disposizioni della tela
Merlino.exe prova      tara lo strumento su storici finti a segnale noto
```

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

### Binario stantio — causa reale del "non scarica" (2026-07-30)

Segnalato di nuovo "l'exe dice ultima estrazione 25/07 ma l'ultima è del 28/07 → lo scaricamento all'avvio non funziona".

**Verificato: il sorgente era corretto.** Entrambe le fonti rispondono 200 e le regex matchano l'estrazione del 28/07:
- SE `superenalotto.com/archivio/estrazioni-2026` → 120 match, primo = `28 luglio 2026 → 1,6,9,43,54,62 J=87 S=69`
- EJ `italia.lottocracked.com/.../estrazioni-2026/` → 60 match, primo = `28 Luglio 2026 → 11,25,40,41,45 E=1,5`

Eseguendo `bin\Release\net10.0\Merlino.exe` (build 28/07) → *"Aggiunte 1 nuove estrazioni"*, archivio a 4227 righe.
Eseguendo `bin\Debug\net10.0\Merlino.exe` (build **16/04/2026**) → *"Nessuna nuova estrazione"* e nessuna riga `>>> ULTIMA ESTRAZIONE`.

**Root cause: l'utente lancia l'exe dalla cartella `bin\Debug\net10.0`, che conteneva un binario del 16/04** — cioè precedente sia al fix URL/markup del 14/07 sia alla riga diagnostica del 28/07. Il vecchio scraper puntava ancora a `/risultati/{yyyy}` con il markup `ball-24px`: 0 match, 0 righe nuove, nessun errore. Non era un problema di fonte né di codice, ma di **build non rigenerata**.

Fix applicati:
1. `dotnet build -c Debug` **e** `-c Release` rigenerati (regola pratica: dopo ogni modifica al sorgente ricompilare la configurazione che si lancia davvero).
2. `SuperenalottoFetcher.cs` / `EurojackpotFetcher.cs`: se la pagina scarica ma il parsing produce **0 estrazioni**, ora stampa
   `[Fetcher] ATTENZIONE: 0 estrazioni riconosciute in {url} ({n} byte scaricati). Markup della fonte cambiato?`
   invece di restituire silenziosamente 0. Distingue "nessuna estrazione nuova" da "parser rotto".
3. `Program.cs`: dopo la riga `>>> ULTIMA ESTRAZIONE …`, se l'archivio è fermo da **più di 5 giorni** stampa
   `!!! ARCHIVIO SE/EJ FERMO DA {n} GIORNI — scraping probabilmente rotto (oppure stai lanciando un exe vecchio) !!!`

Con questi tre segnali, un binario stantio o un cambio di markup diventano visibili al primo avvio.

## Aggiornamento incrementale all'avvio

Ogni volta che l'app parte, `SuperenalottoFetcher.UpdateCurrentYearAsync` fa:

1. Determina l'anno corrente (`DateTime.Now.Year`).
2. Legge `data/{year}.txt` se esiste e trova la data massima `lastDate`.
3. Scarica **una sola** pagina `https://www.superenalotto.com/risultati/{year}` con tutte le estrazioni dell'anno.
4. Parsa le estrazioni, filtra solo quelle con `Data > lastDate`.
5. Merge con le righe esistenti, dedup per data, ordina DESC, riscrive il file (UTF-8 BOM, CRLF, tab esatti).
6. Stampa in console quante estrazioni sono state aggiunte.

Questo viene eseguito **prima** di qualsiasi logica predittiva. Idempotente: un secondo avvio immediato stampa "Nessuna nuova estrazione da aggiungere".

---

# ARCHIVIO STORICO — TUTTO DEPRECATO (17/08/2026)

> Da qui in avanti il contenuto descrive **algoritmi deprecati che non funzionano** e il metro di
> misura con cui erano valutati, anch'esso deprecato. È conservato solo come registro di cosa è
> stato provato, per non riprovarlo. Nessuno di questi file è chiamato dall'applicazione: ognuno
> porta in testa un banner `// DEPRECATO`.
>
> Deprecati anche i due documenti di analisi collegati:
> [segni-ombra-forma-analisi.md](segni-ombra-forma-analisi.md) e
> [bilancia-holdout-analisi.md](bilancia-holdout-analisi.md).
>
> Restano validi e in uso soltanto: lo **scaricamento** (`SuperenalottoFetcher`,
> `EurojackpotFetcher`), il **caricamento storico** (`HistoryLoader`, `DataStore`, `EuroDataStore`)
> e il **formato dati** — tutti documentati nelle sezioni qui sopra.

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

## InstinctEngine — apprendimento online auto-correttivo (2026-07-28)

Settimo motore, e l'unico **non tarato offline**. Tutti gli altri engine fanno random search su parametri fissi e poi li congelano; qui il sistema cammina nella storia dalla prima estrazione all'ultima e ad ogni passo predice → osserva → **si corregge**.

### Meccanica

1. 16 "istinti" (expert) danno ciascuno un punteggio su tutti i numeri, guardando solo `rows[0..t)`.
2. Gli istinti vengono z-normalizzati e fusi secondo la fiducia corrente.
3. Si osserva l'estrazione reale.
4. Aggiornamento moltiplicativo (Hedge): `w_i *= exp(eta · reward_i)` dove `reward_i = (hit_i − baseline) / numActual`.
5. Normalizzazione + **fattore di oblio** verso l'uniforme, così il motore può cambiare idea se cambia il regime.

Anti-leakage strutturale: `Memory.Absorb(t)` è chiamato **dopo** la predizione del passo `t`.

### I 16 istinti

| # | Istinto | Idea |
|---|---------|------|
| 0 | Ritardo | chi manca da più tempo |
| 1 | Caldo | densità nelle ultime 30 righe |
| 2 | Ritmo | gap ≈ gap medio proprio |
| 3 | Vicino | confinanti sulla ruota (circolare) |
| 4 | Specchio | il riflesso `k+1−n` |
| 5 | Decina | famiglia della decina |
| 6 | CifraFinale | stessa cifra finale |
| 7 | Compagni | co-occorrenza storica |
| 8 | Successione | matrice di transizione fra estrazioni consecutive |
| 9 | Eco | ricordo a `k/2`, `k`, `2k` righe fa |
| 10 | Aurea | ritardo su Fibonacci + fase aurea |
| 11 | Contrario | l'esatto opposto del caldo |
| 12 | Sonnambulo | gap > gap medio proprio |
| 13 | Diagonale | scia obliqua nel canvas |
| 14 | Somma | risonanza di somma-cifre |
| 15 | **Caso** | **termometro dell'onestà** — xorshift puro |

L'istinto #15 è il controllo sperimentale: se il caso puro si piazza in alto nella classifica delle fiducie, gli altri istinti non stanno vedendo nulla.

### Auto-tuning

Griglia 3×3 su `eta ∈ {0.05, 0.15, 0.40}` × `oblio ∈ {0.0, 0.02, 0.08}`, si tiene la combinazione col miglior metric online.

### Risultati (run 2026-07-28, 4226 estrazioni SE / 863 EJ)

| Canvas | Online | Baseline | Edge | Passi | Rank del Caso |
|--------|--------|----------|------|-------|---------------|
| SE main (top-6) | 0.416 | 0.400 | +3.9% | 4026 | **7° / 16** |
| SE SuperStar (top-1) | 0.012 | 0.011 | +9.9% | 3112 | 12° / 16 |
| EJ main (top-5) | 0.541 | 0.500 | +8.3% | 763 | 14° / 16 |
| EJ euro (top-2) | 0.336 | 0.333 | +0.8% | 387 | 16° / 16 |

### Il verdetto sta nelle fiducie, non nell'edge

Il risultato più informativo **non** è l'edge ma la **piattezza delle fiducie finali** su SE main: dal 7.8% (Specchio) al 5.4% (CifraFinale), contro il 6.25% dell'uniforme. Dopo 4026 passi di correzione su 4226 estrazioni, il sistema **non è riuscito a distinguere** nessun istinto dagli altri — e il caso puro finisce 7° su 16, in mezzo al gruppo.

Questo è il test più severo mai fatto su Merlino, ed è quello che chiude il discorso: se ci fosse un segnale, 4000 passi di feedback esplicito lo avrebbero trovato. Le fiducie sarebbero divergute. Sono rimaste piatte.

**Eccezione apparente — SE SuperStar**: `Somma` prende il 76.6% della fiducia. Non è un segnale: il target è 1 numero su 90 (hit rate 1.1%), l'aggiornamento moltiplicativo con `eta=0.40` e oblio=0 amplifica sbilanciamenti casuali senza nulla che li riporti verso l'uniforme. È il caso da manuale di collasso della fiducia su rumore, e va letto come artefatto.

**EJ**: gli edge +8.3% (main) e +0.8% (euro) hanno rispettivamente 763 e 387 passi. Con σ ≈ 0.02-0.03 su quei campioni non sono distinguibili da zero.

### Output

`Program.cs` chiude con la sezione `*** LA GIOCATA DELL'ISTINTO ***` che stampa direttamente **6+1** per SE e **5+2** per EJ.

### Output ridotto alla sola giocata (2026-07-30)

Su richiesta esplicita dell'utente ("voglio solo questo", riferito a 6+1 e 5+2), `Program.cs` è stato ridotto a: fetch SE → riga archivio SE → fetch EJ → riga archivio EJ → Istinto → giocata finale. Tutto il resto dell'output è sparito.

- **Non chiamati più** da `Program.cs`: `AnomalyHunter`, `CompressionTest`, `AntiResonanceTest`, `JollyCorrelation`, `PatternMatcher.Sweep/Predict`, `AntiPopular`, `CombinatorialSystems`, retrotest ultime 10, top-12/top-10 con percentuali, "ultime 3 estrazioni".
- **I file degli engine restano tutti sul disco e compilati**: non è stato cancellato nulla, sono solo call rimosse. Per riattivare una sezione basta rimettere la chiamata.
- `InstinctEngine.Run` stampa di suo diagnostica (griglia eta/oblio, fiducie dei 16 istinti, rank del Caso). Non è stato modificato: in `Program.cs` l'output viene silenziato con `Console.SetOut(TextWriter.Null)` attorno alle 4 chiamate, ripristinando `stdOut` fra una e l'altra per stampare un puntino di avanzamento. Così `InstinctEngine.cs` resta intatto e la diagnostica si recupera togliendo due righe.
- Rimossi anche il metric online / baseline accanto alla giocata: restano solo i numeri.

Tempo di esecuzione: ~1 minuto (prima erano molti minuti, dominati dai tuner degli altri engine).

### Probabilità di vincere almeno 10 € — 6+1 vs 7+1 (2026-07-30)

Ipotesi: combinazione 1,00 € + SuperStar 0,50 €/combinazione → 6+1 = 1,50 €, 7+1 integrale (7 combinazioni) = 10,50 €. Quote tipiche punti 2 ≈ 5 €, punti 3 ≈ 25 €; SuperStar a premio fisso (0+SS = 5 €, 1+SS = 10 €, 2+SS = 100 €). SuperStar indipendente dai 6 numeri, P = 1/90.

Distribuzione ipergeometrica dei centri (90 numeri, 6 estratti):

| Centri | 6 numeri | 7 numeri |
|--------|----------|----------|
| 0 | 65,286% | 60,623% |
| 1 | 29,751% | 32,643% |
| 2 | 4,649% | 6,198% |
| 3 | 0,3061% | 0,5165% |
| 4 | 0,0084% | 0,0191% |
| 5 | 0,00008% | 0,00028% |

**6+1**: il punti 2 (~5 €) non raggiunge la soglia, serve punti 3 (0,3146% cumulato) oppure SuperStar centrato con 1-2 punti (1/90 × 34,40% = 0,3822%) → **0,697%, 1 su 143**.

**7+1**: le 7 combinazioni non sono indipendenti — con `j` centri si hanno `7−j` combinazioni da `j` punti e `j` combinazioni da `j−1` punti. Quindi **2 centri = 5 punti-2 ≈ 25 €**, già sopra soglia. E il SuperStar centrato paga su tutte e 7 le combinazioni (anche con 0 centri: 7 × 5 = 35 €) → **P(j≥2) + 1/90 · P(j≤1) = 6,734% + 1,036% = 7,77%, 1 su 13**.

| | 6+1 | 7+1 |
|---|-----|-----|
| Costo | 1,50 € | 10,50 € |
| P(≥10 €) | 0,70% (1 su 143) | 7,77% (1 su 13) |
| Per euro speso | 0,46%/€ | 0,74%/€ |

**11× più probabile a 7× il costo**, ma il valore atteso per euro è identico (un sistema da 7 sono 7 giocate singole): cambia solo la forma della distribuzione, che sposta massa sopra la soglia moltiplicando i premi piccoli. Vincere 10 € avendone spesi 10,50 resta comunque una perdita. Il conto sul 7+1 dipende dalla quota del punti 2 (serve ≥ 2 € perché 5 × quota ≥ 10 €): storicamente sta sui 4-8 €, quindi regge.

### File

| File | Ruolo |
|------|-------|
| `InstinctEngine.cs` | 16 istinti + Hedge online + auto-tuning eta/oblio + giocata finale |

## Segni / Ombra / Forma / Chronos — costrutti inventati da zero (2026-08-01)

Quattro tentativi nati da una richiesta esplicita: **smettere di usare teorie prese in prestito** (quantum walk, Hopfield, Fourier, cristallografia) e inventare costrutti guardando solo questo oggetto. Analisi completa: [segni-ombra-forma-analisi.md](segni-ombra-forma-analisi.md).

Modalità nuove, attive solo da argomento esplicito (il percorso normale dell'app resta invariato, ~1 minuto):

```
Merlino.exe forma      Merlino.exe simboli
Merlino.exe ombra      Merlino.exe chronos
```

| Costrutto | File | E[centri] top-12 | Baseline |
|---|---|---|---|
| Segni (luna, zodiaco, pianeta, Smorfia, trasformazioni) | `SimboliEngine.cs` | **0,8357** (+4,5%) | 0,800 |
| Chronos (debito, memoria lunga, ciclo) | `ChronosEngine.cs` + `ChronosTuner.cs` | 0,8340 (+4,2%) | 0,800 |
| Ombra / Testimoni / Muta | `OmbraEngine.cs` | 0,8243 (+3,0%) | 0,800 |
| Forma (chi² su somma, ampiezza, decine, pari, consecutivi, distanza minima) | `FormaAnalysis.cs` | — | tutti compatibili |

Il numero dei Segni (0,8357) è **nominalmente il migliore mai ottenuto nel progetto**, sopra Nexus (0,833). Ma tutti gli engine nuovi hanno pesi **firmati** e un canale di controllo **"Caso"** di rumore puro, ed è quello a chiudere il discorso:

- I tre canali Caso, rumore per costruzione, sono finiti a **+0,60σ, −0,02σ e −2,13σ**: quella forbice di 2,7σ *è* la banda del rumore su 4.029 punti.
- Ogni costrutto inventato (luna, zodiaco, smorfia, ombra, testimoni, muta, debito, ciclo) cade **dentro** quella banda: il migliore è lo Zodiaco a +1,15σ, sotto due canali di rumore.
- I combinati +4,5% / +4,2% coincidono con il massimo atteso del rumore selezionando il meglio fra ~112 configurazioni (≈ +0,034).
- Su 36 caselle predette dai tre engine, i numeri condivisi da almeno due sono **due** (65 e 77).

`WalkTuner.cs`: tuner walk-forward generico riusabile, così ogni idea futura si misura contro un rumore costruito nello stesso esperimento in poche righe.

## ⚠️ Distribuzione nulla del tuning — il metro era sbagliato (2026-08-01)

`RumoreTest.cs` (`Merlino.exe rumore [repliche]`) fa passare **engine completamente finti** (6 canali di puro rumore) per lo **stesso identico protocollo di tuning** degli engine veri: 100 iterazioni di random search + refinement top-12 sui 4.029 punti. 200 repliche.

**Un engine finto segna in mediana 0,8285, cioè +3,6% sopra la baseline.** Non zero.

| Nullo (200 repliche) | E[centri] | scarto |
|---|---|---|
| mediana | 0,8285 | **+3,6%** |
| 95° percentile | 0,8414 | +5,2% |
| massimo | **0,8503** | **+6,3%** |

Ogni engine mai costruito nel progetto, dentro questa distribuzione:

| Engine | E[centri] | percentile | p-value |
|---|---|---|---|
| Segni | 0,8357 | 83,5% | 0,169 |
| Chronos | 0,8340 | 79,5% | 0,209 |
| Nexus | 0,8330 | 76,5% | 0,239 |
| Oracle | 0,8290 | 55,0% | 0,453 |
| Ombra | 0,8243 | 23,0% | 0,771 |
| Quantum / Genesis / Mosaic | ≤ 0,806 | 0,0% | 1,000 |

**Nessun engine raggiunge p < 0,05.** Il miglior engine finto (0,8503) batte ogni engine vero mai costruito. La banda "+3-4%" celebrata in tutto questo README — il +3,2% dei risultati onesti, il +4,1% di Nexus, il +3,6% di Oracle — **è il pavimento del rumore**, non un edge.

L'errore non era nei modelli ma nel **metro**: si confrontava con la baseline random 0,800, che è il punteggio di un engine finto *non tarato*. Il confronto corretto è con un engine finto *tarato allo stesso modo*: 0,8285. Corollario: il "piccolo guadagno" storico passando da 150 a 300 iterazioni era **selezione, non apprendimento** (più iterazioni ⇒ nullo più alto).

Da qui in avanti, ogni nuovo engine va misurato contro il nullo, non contro 0,800.

## Bilancia — modello consolidato e prima taratura con hold-out (2026-08-11)

Decimo costrutto, e il primo tarato con un **hold-out reale**. Non inventa un paradigma: prende i nove canali che si erano piazzati meglio fra tutti quelli mai provati (Peso, Caldo, Ritardo, Ritmo, Compagni, Successione, Riflesso, Zodiaco + canale di controllo Caso) e li mette sulla stessa bilancia. La novità è il **protocollo di misura**, che era l'ultimo TODO aperto. Analisi completa: [bilancia-holdout-analisi.md](bilancia-holdout-analisi.md).

```
Merlino.exe bilancia [repliche]     (default 60; con 40 il run dura ~7 minuti)
```

Storico tagliato una volta sola: validazione 2.622 punti (dove si scelgono i pesi), **test 1.412 punti mai visti durante la taratura**. In parallelo 40 engine finti passano per lo stesso identico protocollo → distribuzione nulla sul test.

### La taratura non sopravvive al hold-out

| | E[centri] top-12 | scarto |
|---|---|---|
| Validazione (dove i pesi sono stati scelti) | 0,8501 | **+6,3%** |
| **TEST (mai visto)** | **0,7854** | **−1,8%** |

Stesso modello, stessi pesi. Percentile nel nullo **20,0%**, p-value **0,805**: battuto da 4 engine finti su 5. È la dimostrazione diretta, dentro un solo esperimento, di ciò che `RumoreTest.cs` aveva stabilito per via indiretta.

### Più si tara, peggio va

| Variante | parametri liberi | E[centri] sul test | scarto |
|---|---|---|---|
| Argmax su 1.500 configurazioni | 9 | 0,7854 | −1,8% |
| Media dei 25 migliori | 9 (variance-ridotti) | 0,8173 | +2,2% |
| Pesi uguali, 9 canali | 0 | 0,7989 | −0,1% |
| **Pesi uguali, 8 canali (senza il Caso)** | **0** | **0,8293** | **+3,7%** |

La variante con **zero** parametri liberi batte di 4,4 punti quella tarata con 1.500 iterazioni. Alla richiesta "taralo il più preciso possibile", la risposta misurata è **non tararlo affatto**. Per questo la giocata stampata esce dalla variante a pesi uguali, non da quella tarata.

Le due varianti piatte, non avendo parametri liberi, possono usare tutti i 4.034 punti (errore ±0,0127): 9 canali 0,8116 (+0,91σ), 8 canali 0,8183 (**+1,44σ**) — il miglior numero non gonfiato del progetto, e comunque non significativo.

### I canali da soli — la misura più sensibile mai fatta

Nessuna selezione, campione pieno, errore ±0,0127:

| Canale | scarto | sigma |
|---|---|---|
| Successione (Markov) | +2,3% | +1,46 |
| Riflesso | +2,3% | +1,44 |
| Peso (bias palline) | +2,2% | +1,36 |
| Zodiaco | +2,1% | +1,34 |
| Compagni | +0,6% | +0,35 |
| Ritardo | +0,3% | +0,19 |
| Ritmo | −0,3% | −0,22 |
| **Caso (controllo)** | **−0,8%** | **−0,49** |
| Caldo | −3,7% | **−2,32** |

Nessun canale raggiunge 2σ nella direzione giusta; provandone 9 il massimo atteso sotto rumore è ≈ +1,5σ. Il **"Caldo"** — giocare i numeri caldi, pilastro di ogni sistema del lotto mai scritto — è l'unico canale che devia in modo apprezzabile, a **−2,32σ**, e devia *contro*.

### Anti-divisione — l'unico effetto reale del progetto (2026-08-11)

La modalità `bilancia` chiude ora con una sezione che quantifica **quanto si incassa se si vince**, che è cosa diversa dalla probabilità di vincere (quella non cambia mai). Il SuperEnalotto è a totalizzatore: giocare numeri impopolari riduce la probabilità di dividere il montepremi.

Aggiunte a `AntiPopular.cs`: `RelativePopularity`, `PayoutMultiplier` (`E[1/(1+X)]`, `X ~ Poisson(λ)`), `Lambda`.

| Giocata | sei numeri | quanto è giocata |
|---|---|---|
| compleanni (riferimento) | 03 07 11 17 23 28 | **22,65x** la media |
| modello puro | 06 49 62 79 81 83 | 0,19x |
| 90% impopolare | 79 81 82 83 85 86 | 0,03x |

Premio atteso a parità di vincita (1,00 = non diviso con nessuno):

| Giocata | ordinario (7M) | jackpot alto (25M) | jackpot record (80M) |
|---|---|---|---|
| compleanni | 0,883 | 0,657 | **0,325** |
| modello puro | 0,999 | 0,996 | 0,988 |
| 90% impopolare | 1,000 | 0,999 | 0,998 |

Su un jackpot record chi gioca compleanni incassa **un terzo** di chi gioca numeri alti, a parità di 6 centrato (**+204%** per il modello). Ma il guadagno *incrementale* dell'anti-popolare sopra Bilancia è minimo (+1,0%): la giocata del modello è già a 0,19x, con quattro numeri sopra il 60. Il vantaggio è già incassato.

Limite dichiarato: il modello di popolarità è comportamentale, non misurato (i biglietti giocati non sono pubblici). È comunque l'unico effetto del progetto mai sopravvissuto a un test — perché non riguarda l'urna, riguarda le persone.

### Perché "predire per esclusione" non funziona

Escludendo **tutte** le 4.234 sestine già uscite + le 85 sequenze di sei consecutivi + le 1.890 tutte-nella-stessa-decina si eliminano **6.164** combinazioni su 622.614.630: lo **0,00099%**. Le probabilità passano da 1 su 622.614.630 a 1 su 622.608.466. Per raddoppiarle servirebbe escluderne 311.307.315.

Il punto decisivo: pescando a caso, la probabilità di finire nell'insieme escluso è 1 su 101.008 — **il filtro resta inerte 100.000 volte su 100.001**. L'errore è scambiare la rarità di una *classe* per l'improbabilità dei suoi *membri*.

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

- [x] ~~Hold-out split per valutazione onesta~~ — `BilanciaTuner.cs`, validazione 2.622 / test 1.412

**Da fare**:
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
| `BilanciaEngine.cs` + `BilanciaTuner.cs` | Bilancia | Consolidato 9 canali, **taratura con hold-out reale** |

## Storico decisioni

- **2026-04-10**: progetto nato da zero dopo deprecazione di `SelGridViewer/MerlinoEngine`.
- **2026-04-10**: scelto approccio B (Canvas storico) tra A/B/C discussi in chat.
- **2026-04-10**: fonte dati spostata da `lottologia.com` a `superenalotto.com`.
- **2026-04-13**: implementato OracleEngine con paradigma P(≥3). P(≥3)=3.53%.
- **2026-04-14**: implementato GenesisEngine (Fourier, PPM, vortici, Hopfield). P(≥3)=3.48%.
- **2026-04-14**: implementato MosaicEngine (Markov, CA, mod primi, cristallografia). P(≥3)=3.45%.
- **2026-04-14**: implementato QuantumEngine (quantum walk + wavelet). **P(≥3)=3.68% — miglior risultato in assoluto** (+11.5% vs random). La meccanica quantistica simulata trova struttura invisibile agli altri paradigmi.
- **2026-08-11**: implementato **Bilancia** — primo modello del progetto tarato con hold-out reale. La taratura produce +6,3% in validazione e −1,8% sul test mai visto; la variante a **zero parametri liberi** batte quella tarata di 4,4 punti. Il canale "Caldo" a −2,32σ è la sola deviazione apprezzabile del progetto e va in direzione opposta a ogni sistema del lotto.
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
