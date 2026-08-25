# La rosa delle papabili — quanto restringiamo davvero (25/08/2026)

> Richiesta dell'utente: *«trovare altri criteri per scartarne di più, in modo tale da restringere
> al massimo la rosa delle possibili estrazioni papabili... in questo modo prevediamo meglio»*.
> `Merlino.exe rosa [ej]` misura esattamente questo: quanto spazio l'osservazione scarta, e a che
> prezzo.

## Come misura (senza imbrogliarsi)

- **Taglio a due code**: si scarta il troppo strano E il troppo ordinato (la sestina meno strana
  di tutte è la più finta), si trattiene la fascia centrale delle stranezze vere.
- **Scomparto**: catalogo e pesi sul primo 70%; le soglie vengono dalle estrazioni del 30% mai
  usato, ognuna giudicata col contesto della sola storia precedente; le sorteggiate di paragone
  sono giudicate negli **stessi contesti**.
- **Concentrazione** = (frazione di vere trattenute) ÷ (frazione di spazio trattenuto): quanto
  cresce, dentro la rosa, la probabilità di contenere l'estrazione vera. È il restringimento
  onesto, già pagato del suo prezzo.

## Il risultato — SE (124 dimensioni, 846 vere di verifica, 101.520 sorteggiate)

| vere trattenute | spazio scartato | rosa che resta | **concentrazione** |
|---|---|---|---|
| 98,9% | 0,7% | 618 milioni | **1,00x** |
| 94,9% | 4,7% | 593 milioni | **1,00x** |
| 90,0% | 10,1% | 560 milioni | **1,00x** |
| 80,0% | 20,7% | 494 milioni | **1,01x** |
| 50,0% | 50,7% | 307 milioni | **1,02x** |

EuroJackpot: identico (0,96x–1,01x, oscillazione da campione).

## Cosa dice, senza giri di parole

**La rosa si restringe quanto si vuole, ma la concentrazione resta 1,00.** Scartare il 20% dello
spazio costa il 20% delle estrazioni vere; scartarne metà costa metà. La proporzione non si sposta
— e ora è **misurata**, non argomentata: è il numero che risponde alla domanda «così prevediamo
meglio?». Con le forme, no: le forme implausibili sono implausibili perché contengono poche
combinazioni, quindi buttarle via alleggerisce la rosa e la probabilità nella stessa misura.

Questo è coerente con tutto ciò che il progetto ha misurato: le separazioni delle dimensioni sono
reali ma piccole (0,01–0,03 di variazione totale), e il loro aggregato non può concentrare più di
tanto. Il tetto teorico di questa strada è vicino a 1,0 **per costruzione**.

## Dove invece qualcosa si muove — la direzione promettente

La giornata ha prodotto tre indizi **convergenti e indipendenti**, tutti sull'EuroJackpot, tutti
sulla **quarta dimensione (il tempo)** e non sulla forma statica:

1. il **filo certificato** (rimbalzo delle decine attaccate, p 0,020–0,025 su due tagli);
2. la famiglia della **forma che si muove** (somma, ampiezza, salto massimo rispetto all'ultima)
   che regge solo sull'EJ;
3. la **scatola 3D** che legge geometria solo sull'EJ (coppie attigue nel volume: 0,0227 contro
   −0,0164 della scatola a etichette rimescolate), e nella catena «dentro la scatola dell'ultima»
   entra con un B forte (0,57).

Se c'è una strada per «prevedere meglio» nel senso della richiesta, i dati puntano lì: **non la
forma di una estrazione, ma il legame fra la forma di una e quella della successiva, sull'EJ.**
Il prossimo passo naturale è costruire l'esclusione CONDIZIONATA: non «questa forma è rara» ma
«questa forma è rara *dopo* una forma come l'ultima» — il catalogo delle transizioni, con lo
stesso protocollo (scomparto, fondo di rumore, taratura su segnale iniettato).

## L'esclusione condizionata — costruita e tarata (25/08/2026, sera)

Fatta: catalogo delle transizioni (valore di ieri → valore di oggi, per ognuna delle dimensioni,
sul primo 70%), giudizio condizionato al valore dell'estrazione precedente (che alla giocata è
noto), fallback statico dove il valore di ieri è stato visto meno di 20 volte.

**La taratura ha insegnato due cose prima di dare qualunque verdetto:**

1. Il filo **a ripetizione** iniettato (un numero copiato dalla precedente, anche al 25%) la
   condizionata NON lo vede: quel legame lo assorbono le dimensioni che già guardano l'ultima,
   dentro la statica. Questo strumento vede i legami *valore→valore*, non quelli già cablati nel
   contesto.
2. Sull'aggregato di 124+ dimensioni il filo di una sola **si diluisce**. La soluzione è il
   **guadagno d'informazione della transizione** — (stranezza statica − condizionata): la parte
   statica si semplifica e resta solo il legame. Su quello, taglio a una coda.

Con l'iniezione giusta (un **rimbalzo di forma**: ampiezza costretta ad alternarsi):

| rimbalzo iniettato | concentrazione del filo (tagli 95→50) |
|---|---|
| 0,00 | 1,00x piatto (non inventa) ✓ |
| 0,25 | 1,02x–1,05x (lo sfiora) |
| 0,50 | **1,06x–1,19x** (lo vede) ✓ |

La soglia di sensibilità è ~un rimbalzo forzato ogni quattro concorsi.

## Il verdetto della condizionata sui dati veri

| | statica | condizionata | filo (guadagno) |
|---|---|---|---|
| **SE** (846 vere di verifica) | 1,00x | 1,00–1,01x | **1,00–1,01x** |
| **EJ** (262) | 0,96–1,01x | 0,95–1,00x | 1,00–1,03x (oscillazione) |

**Sul SE non c'è legame condizionato utilizzabile.** Sull'EJ il filo certificato (r −0,126 su una
dimensione) è **molto più sottile** della soglia di sensibilità dello strumento: esiste, ma oggi
non restringe la rosa in modo misurabile. Coerente in tutto: il rimbalzo è vero e piccolo. Si
rimisura a ogni crescita dell'archivio — se il filo è reale, prima si rafforzerà il suo p, poi
comparirà nella rosa.
