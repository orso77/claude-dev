# L'Osservatore — la teoria di osservazione delle estrazioni (19/08/2026)

> `Merlino.exe osserva [sei numeri]`. Non predice: **giudica**. Dice se una sestina ha la forma di
> un'estrazione vera, e dice per quali tratti non ce l'ha.

## Da dove nasce

Formulazione dell'utente, riportata perché il criterio è suo:

> *«guardando le estrazioni passate, le ultime 2 ad esempio, e guardando un tuo pronostico ti so
> dire se è plausibile oppure se è una stronzata. tu potenzialmente potresti anche propormi la
> stessa sestina dell'ultima estrazione. i numeri ti darebbero comunque ragione. ma è impossibile
> che esca di nuovo la stessa sestina […] esiste quindi un criterio di distribuzione dei numeri.»*

Il criterio esiste, ed ecco perché: **ogni combinazione è equiprobabile, ma ogni classe di
combinazioni no.** «Tutte e sei nella stessa decina» è una classe con `9 × C(10,6) = 1.890`
combinazioni su 622.614.630; «sparse sul tabellone» ne contiene centinaia di milioni. L'occhio non
giudica la combinazione: giudica la **classe**. Per questo funziona.

Era stato chiesto esplicitamente e non era stato costruito: al primo tentativo era nato un
visualizzatore, al secondo la ricerca era finita per un giorno intero sull'urna. La cosa richiesta
era questa.

## La regola di costruzione: l'occhio dà la direzione, i dati danno la taglia

Nessuna soglia inventata: ogni giudizio è una frequenza misurata su 4.239 estrazioni.

È obbligatorio perché **l'occhio sbaglia sistematicamente la taglia**. Verifica dei criteri
dell'utente sui dati veri:

| | quante volte | su 4.238 |
|---|---|---|
| stessa sestina ripetuta | 0 | **mai — l'utente ha ragione** |
| 6 nella stessa decina | 0 | mai |
| 5 nella stessa decina | 1 | 0,02% |
| **4 consecutivi** | 5 | 0,12% — **è successo** |
| 4 nella stessa decina | 43 | 1,01% |
| **3 consecutivi** | 52 | 1,23% |
| **3 nella stessa decina** | 584 | **13,78%** |
| **2 consecutivi** | 1.184 | **27,94%** |

Direzione giusta, taglia sbagliata di molto: «numeri sequenziali» era fra gli esempi di stronzata,
ma **più di un'estrazione su quattro contiene una coppia di consecutivi**. Un modello che li evitasse
sbaglierebbe dalla parte opposta il 28% delle volte — errore **già commesso** in questo progetto,
quando vietare le celle confinanti fece crollare i consecutivi a 0,0%.

## I 14 tratti

ampiezza · decina più affollata · decine occupate · corsa di consecutivi · coppie di consecutivi ·
quanti pari · quanti bassi · somma · passo minimo · passo massimo · righe della schedina · colonne
della schedina · stessa cifra finale · numeri gemelli.

Ognuno è una domanda con poche risposte: se un tratto avesse troppi valori ogni valore sarebbe raro
e il giudizio non significherebbe niente.

**La stranezza** somma i logaritmi delle frequenze misurate, ma quel numero non viene mai mostrato:
i tratti sono correlati e moltiplicarli sarebbe scorretto. Viene sempre convertito nel **percentile
rispetto alle estrazioni vere**, così la correlazione è già dentro il riferimento e la frase «più
strana del 97% delle estrazioni vere» significa qualcosa.

## La taratura — cosa dice su cose di cui sappiamo la risposta

| cosa | percentile di stranezza |
|---|---|
| estrazione vera tipica | 50,0% |
| **sestina sorteggiata a caso** | **49,9%** |
| 01 02 03 04 05 06 | 100,0% |
| 41 42 43 44 45 46 | 100,0% |
| 01 11 21 31 41 51 (una colonna) | 100,0% |
| 81 83 85 87 89 90 | 100,0% |
| 11 22 33 44 55 66 (gemelli) | 99,6% |
| l'ultima estrazione, ripetuta | 47,3% |

## Il limite, dichiarato invece che nascosto

**Estrazioni vere e sestine a caso stanno allo stesso posto (50,0 contro 49,9), ed è giusto così**:
un'estrazione vera *è* una sestina a caso. Lo strumento non sa distinguere quelle due cose e non
può — non c'è niente da distinguere.

Distingue il **tipico** dall'**atipico**. E serve perché l'urna produce sempre roba tipica, mentre
**un modello può produrre roba atipica** — e i modelli di questo progetto lo hanno fatto due volte.

Stessa onestà sull'ultima riga della taratura: **ripetere l'ultima estrazione non risulta strano
(47,3%), ed è corretto.** La sua forma è ineccepibile; il suo problema è di altra natura e nessuna
osservazione della forma può vederlo.

## La prova che conta — prende il difetto trovato dall'occhio nudo

`Merlino.exe osserva 18 19 20 22 27 29`, la sestina che l'utente aveva segnalato:

| tratto | valore | quanto capita alle vere |
|---|---|---|
| ampiezza | 1 | **0,07%** |
| decine occupate | 2 | **0,19%** |
| righe della schedina | 2 | **0,19%** |
| passo massimo | 1 | 0,75% |
| quanti bassi | 6 | 0,94% |
| corsa di consecutivi | 3 | 1,23% |
| somma | 4 | 1,51% |

**Più strana del 100,0% delle estrazioni vere → STRONZATA.**

E aggiunge la ragione vera, che l'occhio non aveva isolato: non è «tutti sotto il 30» (6 bassi
capita nello 0,94%, raro ma non decisivo), è che quei sei stanno su **due sole decine su nove** con
un ventaglio di 11 su 89 — cose che le estrazioni vere fanno due volte su mille.

## A cosa serve, detto senza girarci intorno

**Non aumenta la probabilità di vincere.** Escludere ogni classe implausibile toglie una fetta
trascurabile delle 622.614.630 combinazioni.

Serve a **collaudare i modelli**, ed è il mestiere in cui questo criterio ha il miglior tabellino del
progetto: l'occhio dell'utente ha trovato 2 difetti veri su 2 tentativi, mentre nove impianti non ne
avevano trovato nessuno. Ora quel giudizio è automatico, quantificato e ripetibile, e dice anche
*per quale tratto* una giocata non va.

## File

| File | Ruolo |
|------|-------|
| `Osservatore.cs` | I 14 tratti, il catalogo misurato, la stranezza in percentile, la taratura |

```
Merlino.exe osserva                       il catalogo + la taratura dello strumento
Merlino.exe osserva 18 19 20 22 27 29     il giudizio su una sestina, tratto per tratto
```
