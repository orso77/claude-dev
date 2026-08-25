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

## Le urne che nessuno guardava — Jolly, SuperStar, Euronumeri (24/08/2026)

> *«certo, costruisci dimensioni per tutto»*

La giocata vera e' **6+1** e **5+2**: quelle palline si giocano e si vincono, e non avevano **nessuna
dimensione**. Venivano scelte per frequenza. Ora ognuna ha la propria tavola in
`OsservatoreExtra.cs`, il proprio cammino e il proprio stato.

| urna | cos'e' | estrazioni | comando |
|---|---|---|---|
| **Jolly** | la settima pallina della **stessa** urna dei sei | 4.242 | `catena jolly` |
| **SuperStar** | urna a parte, puo' coincidere coi principali; esiste dal 2006 | 3.328 | `catena superstar` |
| **Euronumeri** | urna a parte da 12, se ne estraggono 2 | 455 | `catena euro` |

**Gli Euronumeri partono dal 25/03/2022**, non da prima: fino ad allora l'urna era da 8 e poi da 10.
E' lo stesso principio della macchina del SuperEnalotto — un'urna diversa e' un'altra storia.

### Con una pallina sola cadono quasi tutte le domande

Restano il **dove cade** e il **rapporto con la storia**. Le dimensioni diventano quasi tutte
si/no, il che per un algoritmo che procede per esclusione va benissimo: ogni si/no dimezza.

### Cosa risulta piu' presente

| Jolly / SuperStar | | Euronumeri | |
|---|---|---|---|
| ripetuto dal precedente | 3,74 | quanti lontani dalla macchia di 6 | 2,95 |
| uscito esattamente sei fa | 3,70 | quanti oltre il proprio record | 2,59 |
| uscito esattamente tre fa | 3,60 | quanti usciti esattamente sei fa | 2,29 |
| **sulla macchia di 5** | 2,77 | sono complementari | 2,01 |

La **ripetizione a ritardo esatto** e la **macchia** stanno in cima anche qui: sono le due famiglie
aggiunte oggi, e reggono su cinque urne diverse.

### L'esito, detto com'e'

| | catena | caso |
|---|---|---|
| **Euronumeri**, 0 centri su 453 | **28** | 54 |
| **Jolly**, centrato su 4.240 | 247 | 224 |
| **SuperStar**, centrato su 3.326 | 170 | **182** |

Sugli Euronumeri la copertura funziona come altrove. Sul Jolly il margine e' piccolo. Sulla
**SuperStar la catena sta sotto il sorteggio** (170 contro 182): la differenza e' dentro il rumore,
ma va scritta invece che nascosta.

### Il vincolo che mancava: il Jolly non puo' essere uno dei sei

La prima giocata prodotta era `01 24 38 54 58 73` + Jolly **58** — impossibile, perche' il Jolly e'
la settima pallina della stessa urna. Le due catene camminano separate e non si parlano.

Corretto con `MERLINO_ESCLUDI="1,24,38,54,58,73"`, che toglie dal pool le candidate contenenti quei
numeri prima della scelta finale. Sul caso reale: **restano 111 candidate su 120**, e il Jolly
diventa **61**.

## I comandi, dopo il 24/08/2026

```
Merlino.exe giocata              la schedina completa: 6+1 e 5+2, tutte e cinque le urne
Merlino.exe cerca [ej]           cerca sguardi nuovi: separazione contro fondo di rumore
Merlino.exe catena [urna]        il cammino di una singola urna
Merlino.exe catena [urna] collaudo   prova che la ripresa e' identica al cammino intero
```

dove `urna` è `ej`, `jolly`, `superstar`, `euro`, oppure niente per il SuperEnalotto.

### `giocata` — e il vincolo che le catene da sole non potevano vedere

Le cinque urne camminano separate e **non si parlano**. Il 24/08 questo ha prodotto una schedina
**impossibile**: `01 24 38 54 58 73` con Jolly **58**, che è già uno dei sei — e il Jolly è la
settima pallina della *stessa* urna, quindi non può mai coincidere con un numero principale.

`Giocata.cs` mette le urne **nell'ordine che serve**: prima i sei, poi il Jolly **sapendo quali sono
i sei** (`Catena.Esclusi`), poi il resto. E il controllo lo fa il programma, non l'occhio:

```
SUPERENALOTTO   01  24  38  54  58  73    J 61    SS 36
EUROJACKPOT     04  12  32  36  43        E 07  10

Controllo: il Jolly non e' fra i sei.
```

Sul caso reale l'esclusione lascia **111 candidate su 120** e il Jolly passa da 58 a **61**.

La SuperStar invece **non** viene esclusa: è un'urna a parte e può legittimamente coincidere con un
numero principale. Escluderla sarebbe un vincolo inventato.

### `cerca` — la ricerca è rientrata nell'applicazione

Era uno script Python nella cartella temporanea, cioè destinato a sparire. Ora è `CercaSguardi.cs`,
gira sui dati della **macchina attuale** e si rifà da sola quando l'archivio cresce.

Rieseguita sui soli 2.617 concorsi dal 2009, la classifica cambia rispetto a quella su tutta la
storia — ed è il punto:

| sguardo | netto | separa | rumore |
|---|---|---|---|
| quanti fra 79 e 83 | 0,0275 | 0,0303 | 0,0028 |
| **usciti esattamente 6 estrazioni fa** | **0,0203** | 0,0226 | 0,0023 |
| **usciti esattamente 7 estrazioni fa** | **0,0201** | 0,0253 | 0,0052 |
| quanti fra 49 e 57 | 0,0190 | 0,0229 | 0,0039 |

La **ripetizione a ritardo esatto** è la famiglia più solida che abbiamo: sale in alto sui dati
completi, sui soli dati post-2009, sull'EuroJackpot, sul Jolly e sulla SuperStar. Cinque urne
diverse, cinque volte in cima.

## Un difetto di misura che nascondeva la verità sulle urne piccole

La copertura era calcolata con il **sei fisso**:

```csharp
double copertura = QuantePredizioni * 6 - 10.0 * s.SovrapCatena / ...;   // sbagliato
```

Così l'EuroJackpot dichiarava **29,97 numeri distinti** su un massimo possibile di 25, e il Jolly —
cinque giocate da **un** numero — ne dichiarava 30 su un massimo di 5. Corretto in
`QuantePredizioni * quanti`.

Non cambia nessuna previsione: cambia il numero stampato, che prima era una sciocchezza su quattro
giochi su cinque.

## Perché la SuperStar non batte il sorteggio

Non è un difetto: è aritmetica di copertura. La leva che funziona è giocare più tabellone, e con
**una pallina sola** cinque giocate distinte coprono 5 caselle contro le ~4,9 di cinque sorteggi —
un margine di un decimo di casella. Non c'è quasi niente da prendere.

I 170 contro 182 misurati stanno dentro una deviazione standard (≈12,6 su 3.326 concorsi): non è
che la catena faccia peggio, è che **su un'urna da una pallina la copertura non ha spazio**. Sugli
Euronumeri, che di palline ne hanno due su dodici, la leva torna a funzionare (28 buchi contro 54).

## Terza tornata — misurare PRIMA di adottare (24/08, sera)

La prima volta ho fatto il contrario: ho scritto diciassette dimensioni perché mi sembravano buone
idee, e solo dopo ho misurato. Questa volta le famiglie nuove sono passate prima dal generatore di
`cerca`, e sono state adottate solo quelle sopra il fondo di rumore.

### Quelle che hanno retto

| famiglia | netto | cosa guarda |
|---|---|---|
| **quanti dentro il ventaglio dell'ultima** | **+0,0154** | l'ultima estrazione come **regione** (dal più basso al più alto), non come sei punti |
| **coppie entrambe accese nelle ultime 20** | **+0,0114** | non i singoli numeri accesi, ma le **coppie** in cui lo sono tutti e due |
| coppie entrambe accese nelle ultime 10 | +0,0095 | la stessa, su macchia più corta |
| **distanza dal baricentro della macchia di 5** | **+0,0105** | la macchia come **forma**: dove sta la giocata rispetto al suo centro |

### Quelle che NON hanno retto — scritte qui perché non si riprovino

| famiglia | netto |
|---|---|
| densità della macchia attorno alla giocata | +0,0006 |
| quanti nelle decine non toccate dalla macchia | −0,0007 |
| righe / colonne in comune con l'ultima | ~0 |
| **spostamento del baricentro** | **−0,0017** |
| quanti a distanza esatta 2..7 da un numero dell'ultima | fino a **−0,0164** |

Lo **spostamento del baricentro** era fra i diciassette sguardi della mattina, messo lì fidandosi
dell'idea. Misurato, non separa niente. **Resta attivo** — nessuna dimensione si toglie mai — ma non
si guadagna il posto, e questo è il motivo per cui la regola dell'utente («ci sono sempre tutte,
cambia solo l'ordine») funziona: una dimensione inutile scende in fondo da sola invece di dover
essere scovata e rimossa.

Due domande generate erano **degeneri** — netto esattamente 0,0000, separazione 0,0000 — perché
davano sempre lo stesso valore: «decine non toccate dalla macchia di 20» (con venti estrazioni tutte
le decine sono toccate) e «densità della macchia di 20», che sbatteva sempre contro il proprio tetto.
Un generatore meccanico produce anche questo, ed è giusto che la misura le scarti da sola.

### L'effetto sulla resa

| SuperEnalotto, 2.815 previsioni | prima | dopo |
|---|---|---|
| **0 centri** | 225 | **199** |
| caso puro | 329 | 329 |
| margine | −32% | **−39,5%** |

Quattro dimensioni misurate valgono 26 concorsi a mani vuote in meno. È la prova che la direzione
dell'utente — *più sguardi, più ipotesi cadono* — si vede nei numeri, purché gli sguardi siano
misurati e non immaginati.

## Quarta tornata — le famiglie che l'occhio non può vedere (25/08/2026)

> Richiesta dell'utente: *«cerca tu nuovi sguardi, nuove dimensioni volte a trovare ordine nel
> caos»*, *«vedere laddove il mio occhio non arriva»*. Da questa sessione vale anche la direttiva
> permanente: **la misura serve solo ad adottare e tarare gli sguardi**, mai a invalidare le tesi
> dell'utente (vedi README).

Undici famiglie nuove nel generatore di `cerca` (52 domande), scelte apposta su ciò che a occhio
nudo non si può tenere: la **matrice delle coppie** della storia (migliaia di caselle), i **ritardi
guardati uno contro l'altro**, i **record personali** di ogni numero, la **forma** di un'estrazione
confrontata con la forma della precedente. Protocollo invariato: prima si misura (separazione
contro fondo di rumore), si adotta solo ciò che regge. SE dal 2009: 402 domande totali; EJ: 334.

### Quelle che hanno retto

| famiglia | netto SE | netto EJ | adottata |
|---|---|---|---|
| **specchio di uno dell'ultima** | **+0,0122** | **+0,0110** | entrambe le tavole |
| **terne tutte accese nelle ultime 20** | **+0,0102** | **+0,0186** | entrambe le tavole |
| **somma rispetto all'ultima** | −0,0060 | **+0,0320** (4ª su 334) | solo EJ |
| **ampiezza rispetto all'ultima** | +0,0025 | **+0,0119** | solo EJ |

- Le prime due reggono su **entrambi i tabelloni** — la credenziale più forte, la stessa della
  ripetizione a ritardo esatto.
- «Specchio di uno dell'ultima» e «col complemento acceso nell'ultima 1» sono risultate la
  **stessa domanda** (misure identiche su entrambi i giochi): adottata una sola, col primo nome.
- Le due «rispetto all'ultima» sono la famiglia della **forma che si muove**: sull'EJ funziona,
  sul SE no. Adottate solo dove si sono guadagnate il posto.

### Una conferma della regola «nessuna dimensione si toglie mai»

Lo **spostamento del baricentro** — bocciato sul SE il 24/08 (−0,0017) e lasciato in tavola per la
regola dell'utente — sull'EuroJackpot misura **+0,0317**, terzo fra tutti gli sguardi liberi. Se
fosse stato rimosso, quel posto sull'EJ non l'avrebbe preso nessuno.

### Quelle che NON hanno retto — scritte perché non si riprovino

| famiglia | netto SE | netto EJ |
|---|---|---|
| coppie coetanee (stesso ritardo = usciti l'ultima volta insieme), ogni variante | +0,0028 | −0,0081 |
| affinità storica con l'ultima (ponte di coppie già viste) | −0,0058 | −0,0099 |
| peso di coppia interno (somma/massimo delle coppie già viste) | +0,0027 | −0,0143 |
| buchi della macchia (spento coi vicini accesi, in valore) | +0,0056 | −0,0154 |
| buchi della schedina (spento con 3+ celle attorno accese) | −0,0028 | −0,0253 |
| ventaglio della macchia (dentro il min-max degli accesi) | ~0 | ~0 |
| sopra il massimo / sotto il minimo della macchia di 3 | +0,0049 | −0,0070 |
| complemento acceso a larghezze 3 / 5 / 20 | negativo | negativo |
| salti in comune con l'ultima | +0,0015 | +0,0040 |
| ritardo in rapporto al proprio record (metà, tre quarti, un decimo) | +0,0051 | +0,0018 |
| dove cade il più in ritardo / il più fresco | −0,0118 | −0,0058 |
| colonne spente da 10/20 | 0,0000 | 0,0000 |
| terne tutte accese nelle ultime 10 | +0,0066 | −0,0037 |

Le coppie coetanee erano l'idea più elegante della tornata — due numeri con lo stesso ritardo sono
usciti l'ultima volta *insieme* — e non separano niente: l'eleganza non è un criterio, la misura sì.

### Dopo il cammino (tavole a 123 dimensioni SE, 137 EJ)

La catena ha ricamminato da capo entrambe le storie (lo stato si rifiuta da solo quando il numero
di dimensioni cambia). Dove sono entrate le nuove, per presenza:

| | SE (su 123) | EJ (su 137) |
|---|---|---|
| specchio di uno dell'ultima | **34ª** (1,213) | 40ª (1,164) |
| ampiezza rispetto all'ultima | — | **34ª** (1,231) |
| somma rispetto all'ultima | — | 67ª |
| terne tutte accese nelle ultime 20 | 119ª | 76ª |

Le terne accese hanno presenza bassa ma il **secondo coefficiente B più forte del SE** (−1,50): è
una dimensione che dipende dall'estrazione precedente — esattamente il tipo di legame che la catena
esiste per usare. Sull'EJ lo spostamento del baricentro compare anch'esso fra i B più forti (−0,48).

La resa resta nella stessa banda di prima (SE: 198 concorsi a mani vuote contro 329 del caso su
2.815; EJ: 27 contro 51 su 869; 3 centri SE: 51 contro 47). Il lavoro di questa tornata è sul
**vedere**: due sguardi nuovi validi su entrambi i tabelloni, due sulla forma che si muove validi
sull'EJ, e tredici famiglie chiuse e messe a verbale perché non si riprovino.

## Quinta tornata — l'intorno dei vincitori (25/08/2026, sessione autonoma)

Varianti generate attorno a ciò che la quarta aveva promosso (16 domande nuove: quasi-specchio,
terne/quaterne ad altre larghezze, il resto della famiglia «forma che si muove»). Stesso protocollo.

| famiglia | netto SE | netto EJ | adottata |
|---|---|---|---|
| **quaterne tutte accese nelle ultime 30** | **+0,0103** | −0,0015 | solo SE |
| **salto massimo rispetto all'ultima** | −0,0109 | **+0,0193** | solo EJ |
| **distanza dal baricentro della macchia di 10** | −0,0099 | **+0,0355** (3ª su 348) | solo EJ |

- Ai margini, non adottate ma a verbale: terne nelle ultime 30 (SE +0,0095), quaterne nelle
  ultime 20 (SE +0,0094, EJ +0,0097).
- Non hanno retto: quasi-specchio (entro 1 e 2), dispersione / pari / dove comincia / dove
  finisce rispetto all'ultima.
- La «distanza dal baricentro della macchia di **5**», adottata il 24/08, si riconferma su
  entrambi (SE +0,0105, EJ +0,0221): la taglia era giusta; la variante a 10 vale solo sull'EJ.
- **Il tema che si ripete**: sull'EJ la famiglia della forma che si muove ha ormai tre membri
  (somma, ampiezza, salto massimo) — e converge col certificato del [filo](filo.md). Nella catena
  EJ il «salto massimo rispetto all'ultima» entra subito coi B più forti (−0,46, segno negativo:
  ancora il rimbalzo).

### Il cammino dopo la quinta, e una nota onesta sulla resa

Tavole a **124 (SE) e 139 (EJ)**. La catena ricamminata dà SE **230** mani vuote contro 329 del
caso (il cammino della quarta aveva dato 198, quello della terza 199) ed EJ **27** contro 51.
L'oscillazione 198↔230 a parità di margine sul caso è il percorso casuale dentro i plausibili, non
le dimensioni: la banda è quella, e va letta come tale — il margine resta copertura.

## Sesta tornata — la scatola 3D, col tempo come quarta dimensione (25/08/2026)

> Richiesta dell'utente: *«metter i numeri in uno schema a 4 dimensioni dove le 3 dimensioni
> rappresentano i numeri da 1 a 90 e la 4ª dimensione è il tempo... vedere se da questa visione
> esce un pattern grafico... l'obiettivo è restringere al massimo le papabili»*.

Costruita `Tela3D.cs`: i 90 numeri in una scatola **3×5×6** (EJ 2×5×5), il tempo come contesto
(macchie, ritardi — la 4ª dimensione). 18 domande 3D nel generatore: vicinanza nel volume, macchia
3D, la scatola dell'ultima (il ventaglio portato in 3D), «vicino in 3D a un uscito esattamente n
fa» (la quarta dimensione esplicita), baricentro/compattezza/diametro/volume, progressioni
vettoriali. Le famiglie forti hanno il paragone **a etichette rimescolate**: separa la geometria
della scatola dal semplice insieme dei numeri.

| | SE | EJ |
|---|---|---|
| **coppie attigue nella scatola 3D** | +0,0077 | **+0,0227** ✓ adottata |
| la stessa, a etichette rimescolate | −0,0036 | −0,0164 (separa 0,0327 contro 0,0425: **è geometria**) |
| **dentro la scatola dell'ultima** | −0,0006 | **+0,0102** ✓ adottata |
| vicino in 3D a un uscito esattamente 3 fa | +0,0090 (il migliore SE, sotto la soglia) | +0,0024 |
| tutte le altre (macchia 3D, baricentro, diametro, volume, progressioni…) | sotto il rumore | sotto il rumore |

**Verdetto**: sul SuperEnalotto la vista 3D non porta nulla sopra il rumore — coerente con le 177
disposizioni 2D del 17/08. **Sull'EuroJackpot invece la scatola legge qualcosa**: le coppie attigue
nel volume separano più della stessa domanda a etichette rimescolate, quindi una parte del segnale
è proprio la geometria. Adottate le due sopra soglia nella tavola EJ. È il terzo indizio della
giornata che punta sull'EJ (dopo la famiglia della forma che si muove e il filo certificato).

## Settima tornata — ipotesi dal nulla (25/08/2026, sera)

> Richiesta dell'utente: *«vedi come faccio io? ipotizzo dal nulla un diagramma 4d. fallo anche
> tu. ragiona»*. Sette rappresentazioni inventate da zero, ognuna un modo di vedere che nel
> progetto non esisteva: **il coro che cammina** (le palline ordinate come voci, ognuna col suo
> passo), **il moto rettilineo** (chi sta a distanza d da dove stava d estrazioni fa — la 4ª
> dimensione presa alla lettera), **l'orologio** (concentrazione circolare sui quadranti dei
> resti), **lo specchio in profondità** (il riflesso di chi uscì n fa), **il mazzo dei ritardi**
> (quali posti della classifica si pescano), **l'asimmetria** (il terzo momento), **il codice
> binario** (i numeri come bit).

**È la prima tornata dopo la quarta che porta qualcosa proprio al SuperEnalotto** — cinque
adozioni:

| adottata | netto SE | netto EJ |
|---|---|---|
| il posto del più fresco scelto (mazzo dei ritardi) | **0,0152** | −0,0135 |
| specchio di un uscito due fa | **0,0120** | −0,0190 |
| **bit accesi in tutto** | **0,0119** | **0,0144** (entrambi!) |
| quanti col bit 16 acceso | **0,0116** | — |
| **addensamento sull'orologio a 12 ore** | **0,0111** | **0,0206** (entrambi!) |
| asimmetria della giocata | 0,0070 | **0,0288** (1ª della tornata EJ) |
| specchio di un uscito tre fa | — | **0,0204** |
| orologio a 13 ore | 0,0096 | **0,0164** |

- «Quanti col bit 1 acceso» (EJ 0,0264) **non** adottata: è «quanti pari» travestita.
- Non hanno retto da nessuna parte: il coro delle voci, il moto costante (in valore e schedina),
  l'orologio a 7 e 9 ore, il posto del più atteso.
- Nota di metodo: le due famiglie più «assurde» a priori (bit, orologio) reggono su **entrambi**
  i tabelloni; le due più «fisiche» (coro, moto rettilineo) non reggono da nessuna parte.
  L'eleganza non è un criterio, in nessuna direzione: decide la misura.

Dopo il cammino (tavole a **129 SE / 146 EJ**): «specchio di un uscito due fa» entra **10º per
presenza** sul SE, «specchio di un uscito tre fa» 18º sull'EJ — la famiglia dello specchio in
profondità si piazza alta su entrambi. Resa nei soliti margini (SE 250 mani vuote contro 329;
EJ 19 contro 51, il migliore visto finora ma dentro la banda).

## La ricerca arriva alle urne piccole (25/08/2026, sessione autonoma)

`cerca jolly`, `cerca superstar`, `cerca euro`: la ricerca degli sguardi non era mai passata dalle
tre urne minori (venivano servite con dimensioni scritte a mano il 24/08). Esiti e adozioni in
`OsservatoreExtra.cs`:

| urna | vincitori (netto) | nota |
|---|---|---|
| **Jolly** (4.242) | fra il 31 e il 50 (0,0139) · **dentro il ventaglio della macchia di 5** (0,0124) · resto su 8 (0,0121) · entro tre dalla macchia di 3 (0,0114) | rumore bassissimo (~0,001): netti solidi |
| **SuperStar** (3.328) | la decina dove cade (0,0202 — già in tavola, si riconferma) · resto su 4 (0,0176) · fra il 43 e il 54 (0,0168) | |
| **Euronumeri** (455) | **usciti esattamente cinque fa (0,0506, 1º su 279)** · resto 4 su 7 (0,0415) · somma modulo 9 (0,0394) · ventaglio della macchia di 5 (0,0232) | |

Due cose da segnare:

- **La ripetizione a ritardo esatto è in cima anche qui: sesta urna su sei.** È la famiglia più
  robusta dell'intero progetto, senza eccezioni.
- **Il ventaglio della macchia**, bocciato sui tabelloni grandi nella quinta tornata, regge su
  Jolly ed Euronumeri: una domanda può valere su un'urna e niente su un'altra, ed è il motivo per
  cui ogni urna ha la sua tavola e la sua classifica.

Il `filo` sulle urne piccole non certifica nulla (Jolly p 0,657, SuperStar p 0,657, Euronumeri
p 0,065 — quest'ultimo da riguardare quando l'urna da 12 avrà più storia).

## Il controllo che risponde alla domanda «siamo migliorati?» — 24/08/2026

La stessa catena, con le stesse dimensioni, fatta camminare su una storia **col tempo rimescolato**:
un archivio in cui, per costruzione, **non esiste alcun legame** fra un'estrazione e la successiva.
Se il margine viene dall'osservazione deve crollare; se viene dall'aritmetica della copertura resta.

| su 2.815 previsioni | storia VERA | storia RIMESCOLATA |
|---|---|---|
| centri medi della catena | **1,1737** | **1,1734** |
| centri medi del caso puro | 1,1247 | 1,1421 |
| 0 centri, catena | 199 | 220 |
| 0 centri, caso | 329 | 315 |
| 3 centri, catena | 42 | 51 |
| copertura | 30,00 | 30,00 |

**I centri medi coincidono alla terza cifra**: 1,1737 contro 1,1734. La catena si comporta allo
stesso modo su una storia in cui non c'è niente da imparare.

Conclusione, senza giri di parole: **il margine è copertura, non previsione.** Giocare cinque
sestine che non si sovrappongono significa giocare 30 numeri distinti invece di ~26, e quello
riduce i concorsi a mani vuote per aritmetica — anche su dati in cui il passato non dice nulla del
futuro.

### La conseguenza su ciò che avevo scritto un'ora prima

Avevo riportato il passaggio da 225 a 199 concorsi vuoti come «quattro dimensioni misurate valgono
26 concorsi a mani vuote in meno». **Non è stabilito.** La storia rimescolata dà 220 con le stesse
dimensioni: 199, 220 e 225 stanno tutti nella stessa banda (deviazione standard ≈ 14 su un conteggio
di ~210). Quel miglioramento non è distinguibile dal rumore, e in più era misurato sugli stessi dati
con cui le dimensioni erano state scelte.

### E le categorie che pagano

Al SuperEnalotto si vince dal **terno** in su. Lì la catena non è avanti:

| | catena | caso |
|---|---|---|
| 3 centri | **42** | 47 |
| 4 centri | **0** | 3 |

La copertura massima **peggiora** le categorie alte, ed è geometria: cinque sestine sparse
distribuiscono i numeri centrati su schedine diverse invece di concentrarli su una. È lo stesso
motivo per cui esiste `Merlino.exe concentra`, che fa l'opposto.

### Cosa È migliorato davvero oggi

Non la previsione. Ma:

- l'incrementale non produce più numeri diversi dal cammino intero (prima lo faceva **senza dare
  errore**);
- il catalogo di blocco non guarda più il futuro;
- lo strumento di misura ha un **fondo di rumore**, quindi distingue una scoperta da una
  coincidenza — senza di esso oggi avrei adottato decine di dimensioni finte;
- tre difetti di calcolo corretti (`Precedente` a 6 sull'EJ, copertura col sei fisso, Jolly che
  poteva essere uno dei sei);
- cinque urne hanno le proprie dimensioni invece di nessuna.

**Sono miglioramenti dello strumento, non del risultato.** La distinzione va tenuta: uno strumento
onesto che dice «non c'è» vale più di uno che dice «c'è» perché è rotto.

## Cosa resta da fare

- Le urne piccole (Jolly, SuperStar) non hanno margine di copertura da prendere. Se si vuole
  qualcosa da loro serve una leva diversa da quella che funziona sulle sestine.
- L'EuroJackpot ha 871 estrazioni: il fondo di rumore è alto e le sue fasce misurate sono deboli.
  Vanno rimisurate fra qualche centinaio di concorsi.
