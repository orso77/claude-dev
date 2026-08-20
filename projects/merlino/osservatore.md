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

---

# Le 41 dimensioni, e le giocate che l'osservazione non respinge (19/08/2026)

## La correzione di rotta

L'utente ha dovuto ripeterlo per tre giorni:

> *«è forse colpa mia? non ti dico le cose nel modo giusto?»* — no, non lo era.
> *«non solo, ti ho detto di trovare ALTRE dimensioni»*
> *«l'osservazione è proprio questo: osservare una predizione e dire non è possibile»*

L'errore ripetuto: *«aggiungi X come modo di vedere»* veniva inteso come *«verifica se X predice»*.
Sono due richieste diverse. Regola scritta nel nucleo comune come
**Direttiva #0-ter** (`claude-common/ai/00_README_CLAUDE_CLI.md`), valida per tutti i profili e
tutte le sessioni.

## Le dimensioni indicate dall'utente — erano indispensabili

Ritardi e frequenze come **predittori** non funzionano, ed è stato misurato con buona risoluzione
(vede scostamenti dell'1,8%):

| | differenza | scarto |
|---|---|---|
| i sei usciti erano più in ritardo della media? | +0,075 estrazioni | +0,85 errori |
| i sei usciti erano più frequenti della media? | +0,081 uscite | +1,03 errori |

Ma come **osservazione** erano il pezzo mancante. Prova decisiva — la giocata classica dei sei
ritardatari (`05 41 42 48 50 77`):

```
quanti ritardatari      6      0,00%   MAI VISTO
ritardo tipico         11      0,05%   rarissimo
→ 99,6%  STRONZATA
```

**Tutti i 24 tratti di pura forma la dichiaravano «normale».** Senza le dimensioni indicate
dall'utente lo strumento l'avrebbe fatta passare.

## Le dieci dimensioni cercate autonomamente

Famiglie non coperte: il rapporto con l'estrazione **precedente**, la **griglia fisica** della
schedina (34 e 44 sono lontani come numeri e attaccati come caselle), la **struttura** della
sequenza dei salti, la **storia delle coppie**.

isole · ripetuti dall'ultima · vicini dell'ultima · celle attaccate · riga più affollata ·
progressioni aritmetiche · salti ripetuti · quanti centrali · coppie mai viste · oltre il proprio record

Le tre più taglienti:

| dimensione | il fatto misurato |
|---|---|
| **coppie mai viste** | l'83,4% delle vere non ha *nessuna* coppia inedita |
| **oltre il proprio record** | il 94,1% non ha numeri oltre il proprio massimo ritardo storico |
| **ripetuti dall'ultima** | il 66,4% non ripete nulla; tre ripetuti = 0,35% |

**Risultato diretto sull'obiezione originale dell'utente** — proporre la sestina dell'ultima
estrazione:

| | con 14 dimensioni | **con 41** |
|---|---|---|
| l'ultima estrazione, ripetuta | 47,3% — passava | **95,9% — sospetta** |

## Le giocate che l'osservazione non può respingere

```
11  25  32  43  51  79     stranezza al 50,0% delle vere
08  25  31  34  47  49     stranezza al 49,9%
19  22  33  47  63  82     stranezza al 49,9%
22  52  59  76  82  85     stranezza al 49,9%
39  59  62  80  83  85     stranezza al 50,0%
```

Il bersaglio è la **mediana, non il minimo**, ed è il punto meno intuitivo: la sestina *meno strana
di tutte* non è la più plausibile, è **la più finta**. Sarebbe troppo ordinata su 41 tratti insieme,
e le estrazioni vere non lo sono mai. Somigliare a un'estrazione significa avere anche le sue
irregolarità, nella misura giusta.

## Che pattern è, esattamente

È un pattern reale e misurato, ma sta **nella forma del caos, non nella sua sequenza**:

- si può prevedere **come sarà fatta** la prossima estrazione — con precisione, su 41 dimensioni;
- non si può prevedere **quale** sarà.

Le giocate qui sopra non hanno una probabilità maggiore di uscire. Ciò che garantiscono è che una
giocata prodotta dal sistema non sia **respingibile a colpo d'occhio** — il filtro che ai nove
impianti precedenti mancava, e che li faceva sbagliare in modo visibile (le macchie compatte, il
centro del foglio).

---

# I pesi decisi dai dati, e le dimensioni trovate dal sistema (20/08/2026)

## Il principio, formulato dall'utente

> *«devi dirmelo tu in quale direzione spostarlo e che pesi attribuire alle dimensioni.
> è il risultato dell'osservazione»*
> *«misura sempre le osservazioni: servono a dare il giusto peso alle dimensioni e a trovarne di nuove»*

Se i pesi li sceglie chi scrive il codice, l'osservazione non serve a niente. Devono uscire dalla
misura — ed è la misura stessa a far emergere le dimensioni nuove. Questo è ora il funzionamento
normale del sistema, non un passaggio fatto una volta.

## A — Le forze, cercate sui dati (`Merlino.exe pesi`)

500 combinazioni di *forza decina* × *forza ritardo* × *forza frequenza* × *finestra*. Per ognuna,
3.000 giocate generate e misurata la distanza fra i loro istogrammi e quelli delle estrazioni vere,
su tutte le dimensioni. Misurato **senza** il filtro di plausibilità: acceso, sarebbe lui a
raddrizzare qualunque pesatura e le forze risulterebbero indifferenti.

| | valore messo a mano | **risposta dei dati** |
|---|---|---|
| forza della decina | 1,00 | **0,50** |
| forza del **ritardo** | 1,00 | **0,00** |
| forza della frequenza | 0,50 | **0,25** |
| finestra decine | 100 | 100 (confermata) |

**Il ritardo va a zero, e in modo monotono**: tutte e sei le combinazioni migliori hanno
`ritardo = 0,00`, tutte e tre le peggiori hanno `ritardo = 2,00`. Spingere sui ritardatari allontana
le giocate da come sono fatte le estrazioni vere.

## B — La verifica fuori campione (`Merlino.exe misura`)

Pesi ricavati sulle prime 2.119 estrazioni, misura sulle 2.120 successive **mai usate per
ricavarli** — altrimenti si chiederebbe ai dati di confermare ciò che da quei dati è stato estratto.

| impianto | distanza dalle vere |
|---|---|
| **nessun peso** (sorteggio uniforme) | **0,01415** |
| pesi dai dati (0,50 / 0,00 / 0,25) | 0,01424 |
| **pesi a mano** (1,00 / 1,00 / 0,50) | **0,03921** |

**I pesi messi a mano erano il triplo peggio del non pesare affatto** (−177%). Erano il difetto, non
la soluzione. I pesi cercati sui dati li battono nettamente e arrivano appaiati al sorteggio
uniforme — coerente con `ritardo = 0`: tolta la spinta sbagliata, resta un residuo che non sposta.

**La direzione richiesta è quindi: verso lo zero.** Non «pesa di più» o «di meno» il ritardo:
toglilo.

## C — Le dimensioni, e il loro peso misurato

Il peso di una dimensione è la sua **informazione**: quanto la distribuzione sulle estrazioni vere è
lontana dall'essere piatta. Concentrata = un valore fuori dal solito è un segnale forte. Piatta =
non dice mai niente. È una misura, non un giudizio.

**Le cinque che contano di più — tutte trovate misurando, nessuna era fra le prime scritte a mano:**

| dimensione | peso |
|---|---|
| oltre il proprio record | 2,09 |
| coppie specchio | 1,93 |
| quanti iniziano per 9 | 1,75 |
| coppie mai viste | 1,56 |
| progressioni | 1,55 |

**Le cinque che contano di meno — e sono i tratti più classici che esistano:**

| dimensione | peso |
|---|---|
| passo massimo | 0,32 |
| **quanti pari** | **0,49** |
| **ampiezza** | 0,52 |
| **somma** | 0,53 |
| quanti bassi | 0,55 |

Pari/dispari, ampiezza e somma — le prime tre cose che chiunque guarderebbe — pesano **un quarto**
delle dimensioni strutturali emerse dalla misura.

## D — Le dimensioni che il sistema si è trovato da solo

78 domande generate meccanicamente variando i parametri di poche famiglie (*quanti fra a e b* per
decine di fasce, *quanti multipli di d*, *quanti finiscono per c*, *quante coppie distano meno di
s*, *il k-esimo numero*, *il salto k→k+1*), tutte misurate. Non scelte una per una, altrimenti la
selezione sarebbe stata solo la conferma di ciò che si aveva già in mente.

Le sette promosse e aggiunte all'osservatore: `quanti iniziano per 9` (0,630) · `coppie a distanza
1` (0,481) · `quanti multipli di 11` (0,472) · `quanti fra 28 e 36` (0,457) · `quanti fra 82 e 90`
(0,436) · `quanti multipli di 13` (0,423) · `coppie a distanza 2` (0,415).

Le fasce **28-36** e **82-90** sono emerse da sole: nessuno le aveva messe.

## Stato del sistema

- **48 dimensioni**, ognuna pesata per la propria informazione misurata (prima contavano tutte uguale)
- **forze del generatore** prese dai dati, non più a mano
- il ciclo *osserva → misura → ripesa → scopri* è il funzionamento normale

```
Merlino.exe osserva [sei numeri]   il catalogo, la taratura, il giudizio
Merlino.exe pesi                   cerca le forze e propone dimensioni nuove
Merlino.exe misura                 verifica pesi e dimensioni FUORI CAMPIONE
Merlino.exe genera [n]             le giocate, con i pesi usciti dai dati
Merlino.exe cammina [n]            l'osservazione applicata al passato, passo per passo
Merlino.exe ventaglio              di quanto il filtro restringe lo spazio
```
