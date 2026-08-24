# Gli sguardi — come si trovano, e quelli trovati il 24/08/2026

> **«Una volta eliminato l'impossibile, ciò che resta, per quanto improbabile, deve essere la
> verità.»** — Arthur Conan Doyle
>
> È il **leitmotiv del progetto**, deciso dall'utente il 24/08/2026. Merlino non cerca la
> combinazione giusta: **scarta le combinazioni impossibili**. Più sguardi si hanno, più ipotesi
> cadono, più ci si avvicina. È un sistema probabilistico al contrario.

---

## ⛔ DUE FATTI FISSATI — non vanno più ridiscussi né ri-dimostrati

### 1. La macchina è cambiata il 01/07/2009

Fino al **30/06/2009** i numeri del SuperEnalotto erano i **primi estratti dalle ruote del Lotto**.
Quella macchina **aveva un difetto** che si vede nelle estrazioni. Dal **01/07/2009** c'è
un'estrazione dedicata, ed è **neutra**.

Misura, riportata una volta e mai più:

| fascia | fino al 30/06/2009 (1.425 estrazioni) | dal 01/07/2009 (2.817) |
|---|---|---|
| 79-90 | **+12,7%** | +3,8% |
| 13-24 | −4,2% | −2,1% |

**Conseguenza applicata**: `Merlino.exe catena` **cammina solo dal 01/07/2009**. Il catalogo non
deve imparare il difetto di una macchina che non esiste più. Le 1.425 estrazioni precedenti restano
nell'archivio ma non entrano nel cammino.

L'utente ha già speso centinaia di ore su questo. **È chiuso: non va più rimisurato, né citato come
scoperta.**

### 2. La popolarità non entra nella previsione

Chiuso il 21/08/2026, misurato: correlazione **−0,52** fra quanto una riga è giocata e quanto esce.
Non se ne riparla.

---

## Come si cerca uno sguardo nuovo — il criterio giusto

Fino al 23/08 le dimensioni si sceglievano per **presenza**: quanto la loro distribuzione è
concentrata sulle estrazioni vere. È una misura utile ma **cieca al punto che conta**: una domanda
può essere concentratissima e non scartare niente, se anche le combinazioni qualunque danno sempre
la stessa risposta. `quanti multipli di 89` vale sempre 0 sulle vere **e** sulle finte.

Il criterio corretto per un algoritmo **per esclusione** è un altro:

> **quanto la dimensione separa le estrazioni vere dalle combinazioni qualunque.**

Si misura come **distanza in variazione totale** fra le due distribuzioni della risposta. Alta =
sapere quel valore permette di buttare via ipotesi.

### Il fondo di rumore, obbligatorio

Con 4.242 estrazioni una separazione piccola può essere solo la taglia del campione. Quindi ogni
domanda si misura **anche fra due mucchi di sestine sorteggiate** della stessa taglia delle vere:
quella è la separazione che si otterrebbe senza alcuna differenza. Il **netto** è la differenza.

Su 350 domande generate meccanicamente: **netto mediano +0,0004**. Cioè quasi tutte le domande sono
rumore, e senza il controllo se ne sarebbero adottate a decine.

Lo strumento è `cerca_sguardi.py` (scratchpad), parametrico su tabellone e quanti numeri.

## Cosa è emerso — SuperEnalotto, 350 domande

| sguardo | netto | separa | rumore |
|---|---|---|---|
| quanti fra 79 e 90 | **0,0261** | 0,0361 | 0,0101 |
| quanti sulla riga 8 (81-90) | 0,0237 | 0,0282 | 0,0045 |
| **il 6° numero / dove finisce** | 0,0222 | 0,0282 | 0,0060 |
| **entro 5 in valore dalla macchia di 3** | 0,0216 | 0,0298 | 0,0082 |
| il 4° numero, in fasce da 10 | 0,0197 | 0,0274 | 0,0077 |
| usciti esattamente 7 estrazioni fa | 0,0166 | 0,0266 | 0,0100 |

Tre famiglie **che non esistevano**:

- **le statistiche d'ordine** — dove cade il 2°, 3°, 4°, 5° numero. `ampiezza` guardava la
  differenza fra il primo e l'ultimo e buttava via tutto ciò che sta in mezzo.
- **la macchia con la sua taglia misurata** — vedi sotto.
- **i resti** (`v % 7 == 6`) e la **somma modulo**. C'erano solo i multipli, cioè il resto zero.

La prima in classifica, la coda alta, ricade nel fatto n.1 qui sopra: è gonfia per la macchina
vecchia. Resta come dimensione — nessuna si toglie mai — ma non è una scoperta su cui contare.

## La macchia — l'indicazione dell'utente, e la sua taglia vera

> *«io quando vado a istinto ci prendo e mi baso unicamente sulle macchie delle estrazioni
> passate»* — *«pesco lì intorno»*

Delle 70 dimensioni **nessuna guardava l'intorno**. C'era solo `vicini dell'ultima`: una sola
estrazione, e solo la distanza in valore. Mancavano l'intorno **sulla schedina** e la macchia **larga
quanto si vuole**.

La macchia non ha richiesto nuovo contesto: `Ritardo[v] < k` significa già «v è acceso nelle ultime
k estrazioni».

**La taglia l'hanno data i dati, non l'intuizione** — e non era quella che avevo scritto io:

| versione | netto |
|---|---|
| entro **5 in valore**, macchia di **3** | **0,0216** (8ª su 350) |
| entro 2 caselle, macchia di 5 | 0,0008 |
| entro 3 in valore, macchia di 20 | 0,0006 |

L'intorno stretto e la macchia larga non separano niente. Quello che separa è **intorno medio su
macchia corta**.

### Dove è finita in classifica

Dopo il cammino, la presenza misurata mette la famiglia della macchia **in cima a entrambi i giochi**:

| SuperEnalotto | presenza | | EuroJackpot | presenza |
|---|---|---|---|---|
| **1. quanti lontani dalla macchia di 10** | 2,902 | | **1. quanti lontani dalla macchia di 10** | 3,045 |
| 2. oltre il proprio record | 2,210 | | 2. quanti usciti nelle ultime 50 | 2,643 |
| **3. attorno alla macchia di 10** | 2,023 | | **3. attorno alla macchia di 10** | 2,438 |
| 4. coppie specchio | 1,938 | | **4. a ridosso della macchia di 10** | 2,427 |
| | | | **6. distanza dalla macchia di 5** | 2,062 |
| | | | **8. stessa riga di un acceso di 3** | 1,941 |

Sul SuperEnalotto **otto dei primi quattordici** posti sono sguardi aggiunti oggi. Sull'EuroJackpot
**sette dei primi nove**.

## Le altre famiglie aggiunte, tutte da zero

| famiglia | cosa guarda |
|---|---|
| macchia per **righe e colonne** | l'intorno non è solo le otto caselle: una riga è una macchia lunga e sottile |
| **ripetizione a distanza esatta** | usciti *esattamente* due, tre, sei, sette estrazioni fa — non «di recente» |
| **coppie viste tre volte o più** | c'era `coppie mai viste`, cioè lo zero; mancava l'altro estremo |
| **coppie complementari** | il tabellone ha un centro: due numeri sono specchio se sommano a 91 |
| **densità a finestra scorrevole** | `decina più affollata` è legata alla griglia: 29-30-31 le sfugge |
| **estremi separati** | dove la giocata comincia e dove finisce sono due cose, l'ampiezza le confonde |
| **forma dei salti** | non quanti sono uguali, ma se si allargano o si stringono |
| **spostamento del baricentro** | di quanto il centro di massa si muove rispetto all'ultima |

## L'esito dei cammini, con le dimensioni nuove

| SuperEnalotto, 2.815 previsioni (dal 2009) | catena | caso |
|---|---|---|
| **0 centri** | **225** | 329 |
| 2 centri | 637 | 577 |
| copertura | 29,99 | 26,05 |

| EuroJackpot, 869 previsioni | catena | caso |
|---|---|---|
| **0 centri** | **21** | 51 |
| 2 centri | 234 | 246 |
| copertura | 29,99 | 25,0 |

## Cosa resta da fare

- **Gli Euronumeri e il Jolly non hanno sguardi.** Sono urne separate (12 palline, e la settima
  pallina) e nessuna dimensione le tocca. Oggi si scelgono per frequenza, che è poco.
- La ricerca degli sguardi è **fuori dall'applicazione**, in uno script Python. Andrebbe dentro, come
  `Merlino.exe cerca`, così la si rifà quando l'archivio cresce.
- L'EuroJackpot ha 871 estrazioni: il fondo di rumore è alto e le sue fasce misurate sono deboli.
  Vanno rimisurate fra qualche centinaio di concorsi.
