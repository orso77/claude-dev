# Il protocollo a scomparto — l'ipotesi si cerca su un tratto, si verifica sul resto

> 25/08/2026. `Merlino.exe scomparto [ej|tutto|finto|inverso] [percento]` (default: SE dal 2009,
> taglio al 70%). Codice in `Deriva.cs` (`Scomparto`, `ScompartoUna`, `ScompartoProva`).

## Perché esiste

La lezione della caccia libera (`Merlino.exe deriva`, 24-25/08): con uno spazio di ricerca di due
milioni di prove **nemmeno un effetto vero e certo si può certificare** — le storie rimescolate,
facendo la stessa caccia, arrivano a 4 scarti nel 23% dei casi. Lo strumento sa *localizzare* ma
non sa *dimostrare*. Il protocollo a scomparto collassa lo spazio di ricerca a **una** prova:

1. la caccia (`RotturaSuFascia`) gira **solo sui primi N concorsi** (default 70%);
2. ne esce **una** ipotesi: la fascia e il verso della sua inclinazione *adesso* (dopo la
   rottura), rispetto al **neutro teorico** della fascia (largo/k);
3. l'ipotesi si verifica sugli ultimi concorsi, **mai usati per trovarla**, con un solo test a una
   coda contro il neutro.

## ⚠️ La trappola trovata (e corretta) alla prima esecuzione

La prima versione verificava contro il tasso **pre-rottura**. Risultato: SE dal 2009 «confermato»
a p = 0,0035 — con un tasso di verifica del 10,07% su un neutro del 10,00%, cioè **senza che nel
tratto nuovo succedesse niente**.

Il meccanismo: la caccia sceglie il taglio proprio perché rende estremo uno dei due tratti. Se il
tratto estremo è quello **vecchio**, il tratto mai visto — semplicemente normale — se ne discosta
per **regressione verso la media**, e il test «conferma» un puro colpo di fortuna. Un test così
conferma sia gli effetti veri sia gli abbagli: è l'ennesimo criterio-che-non-può-fallire, stavolta
in versione out-of-sample.

**Correzione, doppia:**

- la verifica è contro il **neutro teorico** (largo/k), che non è stimato dai dati e non può
  essere scelto dalla caccia. L'unica ipotesi che il futuro può falsificare è «la macchina
  *adesso* è inclinata» — non «il passato era diverso», che nessun dato futuro può testare;
- **calibrazione dell'intera procedura** (caccia + verifica) su 100 storie rimescolate: il `p`
  empirico è la quota che fa almeno altrettanto, e copre i vizi di selezione residui (es. una
  fascia globalmente sbilanciata per caso, che sopravvive al rimescolamento).

## Il controllo positivo: perché il 2009 non può esserlo, e cosa lo è

**Tempo invertito (fallito, per ragione strutturale)**: invertendo la storia, il tratto difettoso
pre-2009 diventa il blocco di verifica. Ma la parte di difetto che resta *dentro* la scoperta è
corta (576 concorsi al taglio 80%): il suo scarto vero (~2,7) sta **sotto il rumore della caccia**
(~3,5) e la caccia aggancia un abbaglio (fascia 74-78). Non è un difetto dello strumento: gli
stessi dati non possono alimentare sia la scoperta sia la verifica.

Col test corretto anche `scomparto tutto` giustamente **non** conferma: la macchina attuale è
neutra, il difetto 2009 vive nel passato, e la verità su un tratto passato non è certificabile con
estrazioni future.

**Segnale finto iniettato (`scomparto finto`) — il controllo giusto, nella tradizione del
progetto**: nei dati veri dal 2009 si inietta un'inclinazione nota — fascia 30-41 al +X% dal 40%
della storia in poi — e si guarda se l'intera procedura la trova e la certifica:

| segnale iniettato | ipotesi trovata | verifica | p analitico | p empirico | esito |
|---|---|---|---|---|---|
| **+12,7%** (la taglia esatta del difetto 2009) | fascia 35-43 (sull'iniettata 30-41), rottura ~68% | +2,67 scarti | 0,0038 | **0,010** | ✅ certificato |
| **+25,4%** (il doppio) | fascia 29-40, rottura ~60% | +6,17 scarti | ~0 | **0,010** | ✅ certificato |

Il protocollo **vede e certifica un difetto della taglia del 2009** quando vive nel regime
attuale. Nota di rifinitura: a +25,4% ben 22 rimescolate su 100 scendono sotto 0,05 *analitico*
(l'inclinazione globale sopravvive al rimescolamento e la caccia la ritrova) ma **nessuna**
raggiunge il p vero — è esattamente il caso che la calibrazione empirica serve a smascherare.

## I verdetti sui dati veri

| | ipotesi (dalla scoperta) | verifica vs neutro | p analitico | p empirico | esito |
|---|---|---|---|---|---|
| **SE dal 2009** (2.817) | fascia 49-57 sotto il neutro | 10,07% vs 10,00% | 0,565 | 0,545 | ❌ non c'è |
| **EuroJackpot** (871) | fascia 24-28 sotto il neutro | 9,39% vs 10,00% | 0,221 | 0,218 | ❌ non c'è |

**La macchina attuale del SuperEnalotto e quella dell'EuroJackpot non hanno nessuna fascia
inclinata certificabile.** A differenza di tutti i «non c'è» precedenti, questo è **solido**: la
prova era una sola, dichiarata prima, su dati mai usati per trovarla — e lo strumento, tarato sul
segnale finto, certifica una taglia-2009 quando c'è.

## Dettagli tecnici

- Test di verifica: z sulla proporzione della fascia nel blocco di verifica contro largo/k, a una
  coda nel verso di (post-rottura − neutro), varianza binomiale con correzione per estrazione
  senza reimmissione (fattore (k−quanti)/(k−1)).
- `PNormaleOltre`: coda normale standard, Abramowitz-Stegun 26.2.17 (errore < 7,5e-8).
- Il margine di `RotturaSuFascia` (250 concorsi) limita dove la rottura può essere cercata: una
  rottura negli ultimi 250 concorsi del blocco di scoperta è invisibile per costruzione (è la
  ragione geometrica del primo fallimento del tempo invertito al 70%).
- Calibrazione: 100 rimescolate, `p empirico = (almeno+1)/(101)`; sulle storie vere i falsi
  positivi analitici delle rimescolate stanno al 2-9%, compatibili col nominale 5%.
