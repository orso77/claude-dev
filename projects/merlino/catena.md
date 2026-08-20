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
