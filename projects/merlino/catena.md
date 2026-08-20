# La catena degli osservatori (20/08/2026)

> `Merlino.exe catena`. Attraversa tutta la storia una volta, poi riprende da dove era arrivata.
> 4.239 passi in 5 secondi.

## Cosa fa, alla lettera

Richiesta dell'utente, riportata perché l'impianto la segue punto per punto:

> *«osservi le prime 2 estrazioni. crei un modello dando priorità alle dimensioni e generi una serie
> di predizioni plausibili e le passa all'osservatore successivo, che le confronta con la nuova
> estrazione. riapplica l'osservazione, ridefinisce la priorità delle dimensioni, corregge il tiro
> della previsione precedente e fa la previsione della successiva. e così via fino a quella odierna.
> tenendo conto che le estrazioni sono delle costanti farei un sistema incrementale.»*

| la richiesta | come funziona |
|---|---|
| osserva le prime estrazioni | parte dalla 1ª |
| priorità alle dimensioni | `priorità = 1 / (0,25 + errore)`, normalizzata a media 1 |
| serie di predizioni plausibili | 5 per passo, scelte fra 250 candidate |
| le passa all'osservatore successivo | bersagli, errori e priorità si ereditano |
| confronta con la nuova estrazione | conta i centri |
| ridefinisce la priorità | l'errore assorbe lo scarto (media mobile), la priorità si riordina da sola |
| corregge il tiro | il bersaglio si sposta verso il valore vero, passo `1/(i+2)` |
| **incrementale** | stato su file; i lanci successivi attraversano solo le estrazioni nuove |

## Come nasce la priorità

Ogni osservatore porta, per ciascuna delle 48 dimensioni, un **bersaglio** (quanto si aspetta che
valga) e un **errore** (quanto ha sbagliato finora su quella).

La priorità è **l'inverso dell'errore**: una dimensione su cui l'osservatore ci prende quasi sempre
guida la scelta; una su cui sbaglia di continuo conta poco, altrimenti trascina la previsione dietro
al proprio rumore. Non è una scelta di chi scrive il codice — è il resoconto di come ogni dimensione
si è comportata.

## Il confronto truccato, e la sua correzione

Al primo giro l'esito era:

```
centri medi della catena          1,1097
centri medi sorteggiando a caso   0,3989
```

Sembrava che la catena centrasse quasi tre volte il caso. **Era il confronto a essere sbagliato**:
la catena tiene 5 predizioni per passo e si conta la migliore, mentre il braccio del caso ne teneva
**una sola**. Il massimo di cinque tentativi è sempre più alto di uno, anche se sono tutti casuali.

Corretto — il caso gioca con le stesse regole, 5 sestine e si conta la migliore:

| | centri medi |
|---|---|
| la catena | 1,1038 |
| **il caso, stesse regole** | **1,1298** |
| atteso per UNA sestina qualunque | 0,4000 |

**Il caso sta sopra la catena.** E l'1,10 non era merito dell'osservazione: è quello che dà tenere
cinque sestine invece di una, qualunque esse siano.

## Cosa ha imparato la catena

Le priorità che si è data da sola:

| dimensione | priorità | errore tipico |
|---|---|---|
| quanti iniziano per 9 | 2,34 | 0,135 |
| coppie specchio | 2,00 | 0,201 |
| decina più affollata | 1,59 | 0,317 |
| riga più affollata | 1,59 | 0,317 |
| oltre il proprio record | 1,49 | 0,358 |
| ... | | |
| coppie mai viste | 0,36 | 2,231 |
| somma | 0,47 | 1,677 |
| passo minimo | 0,47 | 1,661 |

**Priorità e informazione sono due classifiche diverse**, ed è una distinzione utile: la priorità
premia le dimensioni **più prevedibili**, l'informazione quelle **più concentrate**. `coppie mai
viste` pesa 1,56 in informazione ed è ultima in priorità — dice molto quando la guardi, ma il suo
valore è difficile da azzeccare in anticipo.

## L'impianto incrementale

Un'estrazione passata non cambia mai, quindi il cammino si fa una volta sola e lo stato si salva in
`data/osservatore/catena-superenalotto.txt`. Ai lanci successivi si riprende e si attraversano solo
le estrazioni nuove: da migliaia di passi a uno.

Lo stato **si rifiuta di essere ripreso** se nel frattempo il numero di dimensioni è cambiato: un
osservatore salvato avrebbe imparato guardando altro, e la sua memoria sarebbe sbagliata. Meglio
ricamminare che ereditare una memoria falsa.

`data/osservatore/` è in `.gitignore`: è cache rigenerabile, ed è lo stesso tipo di file che il
17/08 aveva fatto gonfiare GitHub Desktop a 7 GB perché era tracciato.

## Il contesto che si aggiorna invece di ricostruirsi

Ricostruire ritardi, frequenze, coppie viste e record a ogni passo costerebbe il quadrato della
storia (~270 milioni di operazioni). Gli array vivono una volta sola e vengono mutati in posto;
l'oggetto contesto li tiene per riferimento e resta valido. Costo per passo: ~800 operazioni.
È la ragione per cui 4.239 passi durano 5 secondi invece di minuti.

## La previsione per la prossima estrazione

```
22  25  45  54  61  87        12  41  45  57  71  74
15  18  42  62  76  83        24  33  37  46  71  84
14  18  30  43  53  82
```

---

# L'algoritmo per esclusione — 70 dimensioni (20/08/2026)

## La regola fissata dall'utente, e perché è un invariante

> *«le misure, le dimensioni devono esserci sempre tutte. vanno solo ordinate in base al peso che
> rilevi dall'osservazione. più una dimensione una misura è presente più sale, meno è presente più
> scende. la sommatoria di tutte le misure ci aiuta a scartare le ipotesi non plausibili. tra quelle
> che restano ragioniamoci»*
>
> *«in pratica creiamo un algoritmo per esclusione»* — *«più dimensioni abbiamo, più ipotesi
> scartiamo, più ci avviciniamo all'obiettivo»*

**Nessuna dimensione viene mai spenta o rimossa, per nessun motivo** — nemmeno se una misura dice
che «non paga». Cambia solo il posto in classifica, e il posto lo decide quanto quella dimensione è
**presente** nelle estrazioni vere.

La regola è scritta come invariante dentro `Catena.cs`, perché correggeva un errore ripetuto: in
tre giorni il processo dell'utente era stato costruito e smontato **quattro volte**, e ogni volta la
ragione era una metrica di resa scelta da me. Nessuno aveva chiesto di massimizzare i centri.

## Presenza: cosa significa e come si misura

Quanto i valori di una dimensione **si ripetono**. Una dimensione il cui valore più comune copre
quasi tutte le estrazioni è fortemente presente e sale; una che si spalma su dieci valori diversi è
poco presente e scende. Si misura come distanza dall'essere piatta, e **si ricalcola ogni 50
estrazioni** mentre la catena cammina: la classifica si riordina da sola.

## La classifica (70 dimensioni)

| | dimensione | presenza |
|---|---|---|
| 1 | oltre il proprio record | 2,305 |
| 2 | coppie specchio | 1,912 |
| 3 | coppie mai viste | 1,838 |
| 4 | **quanti usciti nelle ultime 50** | **1,809** |
| 5 | quanti iniziano per 9 | 1,795 |
| 6 | progressioni | 1,537 |
| 7 | corsa di consecutivi | 1,485 |
| … | | |
| 47 | quanti pari | 0,494 |
| 48 | passo massimo | 0,316 |

`quanti pari` sta in fondo e **continua a partecipare** con il suo 0,494. È la differenza rispetto a
prima, quando avrei proposto di eliminarla.

## Il secondo blocco di dimensioni, trovato dal sistema

Da 48 a **70**, con famiglie mai generate prima: coppie con somma o differenza multipla di *m*,
coppie sulla stessa diagonale della schedina, numeri con cifre consecutive, decine rimaste vuote,
decine vuote di fila, metà più affollata, quanti usciti nelle ultime 20 e 50, somma dei ritardi,
più otto fasce numeriche emerse dalla misura.

`quanti usciti nelle ultime 50` è entrata **direttamente al 4° posto**: non era stata prevista.

## La previsione condizionata, e il controllo che l'ha fermata

Formulazione dell'utente: *«a fronte di x y z prevedo z1, e a fronte dell'estrazione posso
correggere la previsione — con l'osservatore successivo»*. Costruita: per ogni dimensione
`previsione = A + B × (valore nell'ultima estrazione)`, con A e B corretti a ogni passo dall'errore.

`B` parte da zero e si muove solo se la correzione lo spinge. Risultato: **|B| medio 0,2897**,
diverso da zero, con `passo minimo` a 1,56 e `coppie mai viste` a −1,16.

Controllo su storia col tempo mescolato, dove il legame fra un'estrazione e la successiva non esiste
per costruzione: **|B| medio 0,2526**. La stessa cosa. Quel 0,29 non misura una dipendenza — misura
la procedura di correzione che insegue il proprio rumore.

## La misura della dispersione — un difetto trovato guardando

Le cinque predizioni di ogni passo, quando erano scelte tutte vicine allo stesso bersaglio, **si
somigliavano fra loro** più di cinque sorteggiate: `0,440` numeri in comune contro `0,403`. Con «la
migliore di cinque», l'ammassamento è un difetto — cinque sestine simili coprono meno tabellone.

Osservazione dell'utente: la dispersione fra le giocate **è essa stessa una dimensione**, da
misurare. Ed è una famiglia che non esiste ancora: tutte e 70 le dimensioni giudicano *una sestina
alla volta*, nessuna guarda *l'insieme delle cinque* — mentre la giocata reale è un insieme.

## Stato

- **70 dimensioni**, tutte sempre attive, ordinate per presenza ricalcolata durante il cammino
- **sommatoria pesata** di tutte = criterio di esclusione (si scarta il 10% più implausibile)
- **cammino completo** su 4.239 estrazioni in 25 secondi
- **incrementale verificato**: al secondo lancio riconosce di essere già arrivata e non ricammina
- lo stato si rifiuta di essere ripreso se il numero di dimensioni è cambiato

### La previsione corrente

```
07  37  55  71  79  84        07  31  43  66  81  89
07  20  41  42  74  77        03  08  35  56  63  69
21  52  60  67  75  77
```

---

# Gli sguardi di blocco — giudicare l'insieme, non la singola giocata (20/08/2026)

## Il buco che colmano

Tutte e 70 le dimensioni giudicano **una sestina alla volta**. Ma la giocata vera è un **insieme**:
si giocano cinque sestine, non una. E un insieme può essere sbagliato anche se ogni sestina che lo
compone è impeccabile — cinque giocate perfettamente plausibili ma ammassate sugli stessi numeri
coprono meno tabellone di cinque sparse.

Il difetto era stato misurato e nessuna dimensione poteva vederlo, perché nessuna guarda più di una
sestina. L'ha indicato l'utente: *«perché nella previsione non ci mettiamo le 5 sparse e poi le
confrontiamo e magari ci costruiamo sopra una qualche dimensione?»*

## Il riferimento: cinque estrazioni vere consecutive

Non un ideale deciso a tavolino. Il catalogo di blocco si costruisce facendo scorrere una **finestra
di cinque** su tutta la storia — l'unico insieme di cinque sestine di cui si sappia con certezza che
«è fatto come vanno le cose».

## I dodici sguardi

copertura del blocco · numeri ripetuti nel blocco · il più ripetuto · massimo in comune fra due ·
somiglianza media · decine coperte · decine scoperte · decina più servita · squilibrio fra le metà ·
colonne coperte · buco più largo · giocate senza ripetizioni

## Il risultato — il difetto corretto e capovolto

```
numeri in comune fra le cinque predizioni

   prima (mirate allo stesso bersaglio)   0,440   ammassate
   cinque sorteggiate a caso              0,402
   con gli sguardi di blocco              0,313   piu' sparse del caso
```

**È la prima volta che il sistema batte il sorteggio su una proprietà misurabile.** Non sui centri —
sulla proprietà che l'utente aveva individuato come quella che conta quando si gioca un insieme.

## La scelta golosa, e perché non si cerca l'ottimo

Si parte da una giocata e ogni volta si aggiunge quella che rende il blocco meno implausibile. Non è
garantita ottima, **ed è voluto**: cercare l'ottimo produrrebbe l'insieme più regolare possibile, che
è esattamente ciò che cinque estrazioni vere non sono mai. Stessa ragione per cui la singola giocata
punta alla stranezza mediana e non alla minima.

## Un limite da tenere presente

L'utente ha osservato: *«più è ampia l'osservazione più riusciamo a classificare bene le
dimensioni»*. Vero, e qui c'è un limite reale: il catalogo di blocco ha 4.235 finestre contro le
4.239 estrazioni singole, ma **le finestre si sovrappongono** (scorrono di uno), quindi
l'osservazione indipendente è molto più piccola di quanto il numero suggerisca. Con dodici sguardi,
la classifica di blocco è più fragile di quella delle 70 singole.

## Stato finale

- **70 dimensioni** sulla singola giocata + **12 sguardi di blocco** sull'insieme
- tutte sempre attive, ordinate per presenza ricalcolata durante il cammino
- doppio vaglio: la sommatoria delle singole esclude le sestine implausibili, quella di blocco sceglie
  quali cinque formano l'insieme meno implausibile
- cammino completo su 4.239 estrazioni in **32 secondi**, incrementale verificato

### La previsione corrente

```
07  37  55  71  79  84        05  11  17  54  72  76
06  07  20  26  36  64        03  05  19  49  50  57
43  55  65  70  78  80
```
