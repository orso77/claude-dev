# Le strategie di disposizione — misurate tutte, e il verdetto (24/08/2026)

> `Merlino.exe strategie [ej]`
>
> **Domanda**: a parità di numeri giocati, come vanno disposti fra le schedine?
> **Risposta**: non conta. In nessun modo. Ed è dimostrabile, non solo misurabile.

## Perché la domanda sembrava aperta

Il 24/08 il controllo col tempo rimescolato ha chiuso la domanda «quali numeri giocare»: la catena
fa 1,1737 centri medi sulla storia vera e 1,1734 su una storia in cui il passato non dice nulla del
futuro. Non c'è niente da leggere, e ora è misurato con un controllo invece che ipotizzato.

Restava una seconda domanda, **indipendente dalla prima e che non richiede di prevedere nulla**:
cinque sestine sono trenta caselle, e si possono spargere su trenta numeri distinti oppure ammassare
su un gruppo piccolo facendo condividere numeri alle schedine.

L'osservazione che l'aveva aperta era giusta: al SuperEnalotto **non si vince niente con uno o due
numeri**, si vince dal terno in su. E la copertura massima, che è quello che la catena fa oggi,
sembrava ottimizzare proprio la categoria che non paga — 199 concorsi a mani vuote contro 329 del
sorteggio, ma 42 terni contro 47.

## Il primo giro, e perché era una trappola

Un solo giro su 2.817 concorsi:

| strategia | concorsi vinti | schedine con 3 centri |
|---|---|---|
| sparse | **47** | 46 |
| gruppo8 | 25 | **61** |

Sembrava un risultato: *spargere vince più concorsi, concentrare produce più schedine vincenti — e
ogni schedina vincente incassa, quindi concentrare paga di più*. Il ragionamento sta in piedi, e il
numero sembrava confermarlo (+33% di terni).

**Era rumore.** Su ~44 schedine vincenti attese, lo scarto tipico di un singolo giro è ±7: un 46
contro un 61 è dentro due scarti, e con otto strategie a confronto una che sballa è la norma.

## La misura vera — 300 giri indipendenti

| strategia | schedine vincenti | 3 centri | 4 centri | concorsi vinti | mai un centro |
|---|---|---|---|---|---|
| **attesa teorica** | **44,3** | | | | |
| gruppo8 | 44,9 | 43,7 | 1,2 | 21,2 | 1.584 |
| gruppo20 | 44,8 | 43,6 | 1,2 | 41,2 | 795 |
| **sparse** (quella di oggi) | **44,7** | 43,5 | 1,2 | **44,7** | **226** |
| caso | 44,7 | 43,5 | 1,2 | 44,5 | 336 |
| gruppo12 | 44,7 | 43,5 | 1,2 | 34,5 | 1.197 |
| gruppo15 | 44,5 | 43,3 | 1,1 | 38,1 | 1.004 |
| gruppo30 | 44,4 | 43,2 | 1,2 | 42,8 | 589 |
| gruppo10 | 43,8 | 42,5 | 1,3 | 29,5 | 1.370 |

**Tutte e otto entro ±0,6 dall'attesa.** Anche le quaterne, che nel giro singolo davano 1,4 contro
0,9, si allineano a 1,1–1,3 per tutte.

Stesso esito sull'EuroJackpot: attesa 20,8, misurate fra 20,0 e 22,0.

## Perché doveva andare così — la dimostrazione, che vale più della misura

Non serviva simulare: **il valore atteso non poteva cambiare**, per linearità.

Il numero medio di schedine che fanno *c* centri è la somma, su ciascuna schedina, della probabilità
che quella schedina faccia *c* centri. E ogni singola schedina, presa da sola, è una combinazione
qualunque:

- in `sparse` la seconda schedina pesca fra gli 84 numeri rimasti — ma quali siano gli 84 è a sua
  volta casuale, quindi per simmetria la schedina resta uniforme su tutte le C(90,6);
- in `gruppo8` la schedina pesca da un gruppo di otto, ma il gruppo è casuale: di nuovo uniforme.

La dipendenza *fra* le schedine è enorme e cambia tutto ciò che riguarda la **congiunta** — ma la
media di una somma non dipende dalle dipendenze. Solo la **varianza** ne dipende.

## Cosa cambia davvero: la forma della vincita nel tempo

| | sparse | gruppo8 |
|---|---|---|
| concorsi in cui si vince qualcosa | **44,7** | 21,2 |
| concorsi chiusi a mani vuote | **226** | 1.584 |
| scarto sulle schedine vincenti | **6,4** | 10,9 |
| numeri distinti giocati | 30,0 | 8,0 |

Concentrare **dimezza** il numero di volte in cui si porta a casa qualcosa e, quando capita, fa
vincere più schedine insieme. Spargere fa vincere più spesso, poco per volta. **Il totale è lo
stesso.**

## Cosa è stato implementato

**Niente di nuovo, ed è il risultato.** La strategia già in uso — cinque sestine senza numeri in
comune, trenta numeri distinti — è la migliore sull'unico criterio su cui le strategie differiscono
davvero: massimizza i concorsi in cui si vince qualcosa (44,7) e minimizza quelli a mani vuote (226).

Non è stata scelta per quel motivo: c'era arrivata inseguendo la riduzione dei buchi, che è una
metrica che non paga. Ma la misura dice che è comunque l'opzione giusta, e ora si sa **perché** e si
sa **quanto vale** — cioè nulla in denaro atteso, tutto in regolarità.

L'alternativa `concentra` (`SistemiCopertura.cs`, `Concentrazione.cs`), costruita per garantire il
terno su un gruppo, resta valida come **garanzia** — «se fra i numeri del gruppo ne escono tre,
almeno una schedina li contiene» è un teorema, non una previsione — ma ora si sa che non aumenta
quanto si vince: sposta la stessa vincita attesa verso eventi più rari e più grossi.

## La conclusione, in una riga

Merlino ha ora misurato le **due** domande possibili — *quali numeri* e *come disporli* — con un
controllo per ciascuna. La risposta è la stessa: non si può fare meglio del caso. La differenza è
che adesso è dimostrato invece che sospettato, e lo strumento che lo dice è affidabile.
