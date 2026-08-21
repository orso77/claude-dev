# L'incrementale che mentiva — e i tre difetti che lo facevano mentire (21/08/2026)

> Richiesta dell'utente: *«adesso lavora sull'incrementale. assicurati che funzioni bene e che non
> dia risultati errati (nel senso diversi dall'elaborazione totale)»*.
>
> Esito: **ripresa e cammino intero ora producono lo stesso stato bit per bit e la stessa giocata**,
> verificato su 9 punti di rottura diversi e su entrambi i giochi.

## Come si è visto il difetto

Lanciando `Merlino.exe catena` per la giocata del 21/08 la catena ha risposto *«già arrivata
all'ultima estrazione, niente da attraversare»* e ha stampato cinque sestine in mezzo secondo.

Quei numeri **non valevano niente**, e non c'era nessun errore a dirlo. Il segnale era nella tabella
stampata subito sopra:

```
presenza di tutte e 70 le dimensioni      1,000
|B| medio su tutte e 70 le dimensioni     0,0000
QUANTE VOLTE SI CENTRA                    (tabella vuota)
```

Una presenza identica su tutte e settanta è impossibile per costruzione: la presenza *è* la misura
di quanto le dimensioni differiscono fra loro. Era il valore di inizializzazione.

**È il difetto peggiore che questo progetto possa produrre**: non dà errore, non si pianta, e
restituisce cinque sestine dall'aria perfettamente normale. Stessa famiglia del *binario stantio*
del 30/07 — un risultato plausibile e sbagliato, che nessuno ha motivo di controllare.

## Difetto 1 — lo stato salvava un quinto della memoria

`Salva` scriveva 73 righe: `arrivata`, il resoconto, e per ogni dimensione `bersaglio`, `errore`,
`priorità`. Tutto il resto ripartiva dai valori di inizializzazione:

| non salvato | conseguenza alla ripresa |
|---|---|
| **`Catalogo`** | in `Plausibili` ogni valore vale `0,5` per ogni candidata → **tutte le 2.000 candidate ricevono lo stesso punteggio**, l'ordinamento diventa arbitrario e **l'esclusione non esclude niente** |
| **`Presenza`** | tutte a 1,000: la classifica delle dimensioni sparisce, la sommatoria pesata diventa non pesata |
| `A`, `B`, `Ultimo` | la previsione condizionata riparte da zero |
| istogrammi, sovrapposizioni, `CoppieViste`, `CentriPlausibile` | il resoconto stampato è falso |

Il catalogo è la memoria che conta: senza di lui restava in piedi la sola copertura, cioè le cinque
sestine venivano scelte per non sovrapporsi ma **fra candidate non filtrate**.

Non colpiva solo il lancio a zero passi: riprendendo con **una** estrazione nuova il catalogo
avrebbe contenuto quell'unica estrazione.

**Correzione**: si salva tutto, catalogo compreso (una riga per dimensione, `valore:conteggio`). E
`Riprendi` **rifiuta** uno stato incompleto invece di completarlo con i default — una memoria
parziale non è un inconveniente, è la fonte del difetto.

## Difetto 2 — il caso dipendeva da come ci si era arrivati

```csharp
ulong seme = 0x853C49E6748FEA9BUL + (ulong)stato.Arrivata;   // prima
```

Il seme veniva fissato **una volta all'inizio del lancio** e poi scorreva per tutti i passi. Il passo
4.000 pescava numeri diversi a seconda che ci si fosse arrivati in un colpo solo (seme partito da
`BASE+0`) o riprendendo da uno stato (seme partito da `BASE+3.999`).

Da solo bastava a rendere impossibile l'equivalenza, **anche salvando tutta la memoria**.

**Correzione**: `SemeDelPasso(i)`, funzione solo di `i`. Due strade diverse per arrivare allo stesso
passo pescano lo stesso caso.

## Difetto 3 — il catalogo di blocco guardava il futuro

Questo non lo cercavo: è saltato fuori perché era l'ultima differenza rimasta.

`Blocco.Catalogo(vere)` costruiva il catalogo delle finestre di cinque su **tutta** la storia, e poi
quel catalogo serviva a scegliere le cinque giocate **anche al passo 5**. Cioè il passo 5 veniva
giudicato con statistiche ricavate dal proprio futuro: **leakage**, e in un progetto che ha come
regola dichiarata «per predire `t` si guardano solo le righe prima di `t`».

Ed era anche l'ultima causa di divergenza: un lancio fatto quando l'archivio aveva 700 estrazioni
costruiva un catalogo diverso da uno fatto con 870, quindi le stesse identiche condizioni davano due
giocate diverse.

**Correzione**: `CatalogoFinoA(vere, n)` usa solo le finestre interamente contenute nelle prime `n`
estrazioni, e il catalogo **cresce durante il cammino** — quando l'estrazione `i` è nota, la finestra
che finisce su di lei entra, e al passo dopo è passato.

## Il difetto più sottile — la somma in virgola mobile non è associativa

Dopo le prime due correzioni lo stato era ancora diverso, ma **all'ultimo bit**:

```
A: ... 0.4506324673438987
B: ... 0.4506324673438991
```

Causa: `RicalcolaPresenza` sommava l'entropia iterando un `Dictionary`. Un dizionario si enumera
nell'**ordine di inserimento delle chiavi** — cronologico nel cammino intero, crescente in uno
ricaricato da file. Due ordini diversi, due somme diverse all'ultimo bit.

E quel bit non restava innocuo: cambiava l'ordinamento delle candidate e quindi **la giocata**.

**Correzione**: `.OrderBy(x => x.Key)` prima di sommare, sia per le 70 dimensioni sia per gli sguardi
di blocco. Vale la pena ricordarlo perché è invisibile alla lettura del codice: due somme degli
stessi identici numeri possono dare risultati diversi.

## Il collaudo — `MERLINO_FERMA`

Serviva un modo di *dimostrare* l'equivalenza invece di dichiararla. `MERLINO_FERMA=n` fa finta che
l'archivio finisse alla n-esima estrazione: si cammina fino a `n`, si salva, si rilancia senza la
variabile, e si confronta lo stato finale con quello di un cammino fatto tutto in una volta.

Non è una scorciatoia di calcolo: esiste solo per il collaudo.

| gioco | punti di rottura provati | esito |
|---|---|---|
| EuroJackpot (870 estrazioni) | 50, 100, 435, 700, 865, 869 | **stato identico, hash uguale** |
| EuroJackpot, tre riprese di fila | 50 → 300 → 700 → fine | **identico** |
| SuperEnalotto (4.240 estrazioni) | 1.000, 3.000, 4.237 | **identico** |

Confronto fatto sull'**hash del file di stato** — 173 righe per l'EJ, comprensive di catalogo,
presenza, A, B e istogrammi — e sulla giocata stampata.

## Cosa è cambiato nei numeri, e va detto

Le correzioni 2 e 3 cambiano il cammino: il caso di ogni passo è un altro, e il catalogo di blocco
non vede più il futuro. Le cifre di riferimento vanno quindi aggiornate.

| SuperEnalotto, 4.238 previsioni | catena | caso puro | prima (con leakage) |
|---|---|---|---|
| **0 centri** | **338** | 530 | 304 contro 502 |
| 1 centro | 2.905 | 2.756 | |
| 2 centri | 919 | 881 | |
| copertura | 30,00 numeri distinti | 26,01 | |

| EuroJackpot, 868 previsioni | catena | caso puro |
|---|---|---|
| **0 centri** | **24** | 51 |
| 1 centro | 554 | 548 |
| 2 centri | 272 | 246 |
| copertura | 29,97 numeri distinti | 25,06 |

Il vantaggio di copertura resta e resta grosso (**−36%** di concorsi a mani vuote sul SuperEnalotto,
**−53%** sull'EuroJackpot), ma è un po' più piccolo di quello annunciato il 20/08: parte di quel
−39% veniva dal catalogo di blocco che guardava avanti.

**Le due giocate consegnate all'utente il 21/08 non cambiano**: `06 45 53 58 62 75` al
SuperEnalotto e `06 10 26 32 41` all'EuroJackpot uscivano identiche prima e dopo le correzioni.

## File toccati

| file | cosa |
|---|---|
| `Catena.cs` | `Salva`/`Riprendi` con memoria completa e rifiuto degli stati parziali; `SemeDelPasso`; presenza ricalcolata solo su `i % 50` più una volta in `Mostra`; catalogo di blocco fatto crescere nel cammino; `MERLINO_FERMA`; somma dell'entropia in ordine di chiave |
| `Blocco.cs` | `CatalogoFinoA`, `Aggiungi`, `Presenze`; entropia in ordine di chiave; `K` per la taglia del tabellone |

## Cosa resta aperto

- **Il collaudo non è automatico.** `MERLINO_FERMA` esiste, ma il confronto fra i due cammini lo si
  fa a mano da PowerShell. Andrebbe un `Merlino.exe catena collaudo` che li esegue e confronta da
  solo, altrimenti fra un mese nessuno lo rifarà.
- Lo stato dell'EuroJackpot pesa 173 righe, quello del SuperEnalotto di più: il catalogo cresce con
  i valori distinti. Non è un problema oggi, ma non è limitato.
