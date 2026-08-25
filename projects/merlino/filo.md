# Il filo — il coefficiente B messo nello scomparto (25/08/2026)

> Sessione autonoma su mandato dell'utente: *«lavora in autonomia… continua ad affinare,
> migliorare, tentare»*. Il candidato era stato lasciato sul tavolo dalla sessione precedente:
> alcune dimensioni della catena dipendono dall'estrazione precedente (il coefficiente B), *«da
> confermare su un blocco mai usato prima di dire altro»*. Questo file è quella conferma.

## La domanda, e la trappola da evitare

Un B grande ha due origini possibili, che non sono la stessa cosa:

1. **meccanica delle finestre** — le dimensioni costruite su tratti di storia (la macchia, le
   terne accese) si somigliano da un passo all'altro perché la finestra condivide quasi tutto,
   anche se le estrazioni non si parlano affatto;
2. **un legame vero** fra ciò che esce e ciò che è appena uscito.

Le due si separano con le **storie rimescolate**: distruggono l'ordine del tempo conservando le
estrazioni, quindi conservano tutta la parte meccanica e cancellano solo il legame vero. Ciò che
conta è l'**eccesso** di autocorrelazione della storia vera sopra le rimescolate.

E con 123 dimensioni, cercare e certificare sugli stessi dati è la trappola già vista col 2009:
la caccia produce eccessi da sola. Quindi **protocollo a scomparto**: l'ipotesi si cerca sul primo
70% (la dimensione con l'eccesso più forte, col suo verso — UNA sola), si verifica sul 30% mai
usato, p empirico contro 200 storie rimescolate valutate sullo stesso tratto.

`Filo.cs`, comando `Merlino.exe filo [ej]` e `filo prova [probabilità]`.

## La taratura, prima di credere a qualunque verdetto

Storia finta di 2.800 sorteggi puri in cui si **inietta un filo noto**: con probabilità data, un
numero dell'estrazione t è copiato dalla t−1.

| filo iniettato | ipotesi trovata sul 70% | p sulla verifica | verdetto |
|---|---|---|---|
| **nessuno** (0,00) | una spuria (eccesso 3,28 — atteso con 123 dimensioni) | **0,935** | non certifica ✓ |
| debole (0,10) | quanti fra 19 e 27 | 0,179 | non certifica |
| **0,25** | quanti fra 37 e 45 | **0,005** | **certifica ✓** |

Lo strumento non si fa ingannare dal rumore, non vede un filo sotto ~una ripetizione forzata ogni
quattro concorsi, vede bene da 0,25 in su. Nota: l'ipotesi certificata a 0,25 non è «ripetuti
dall'ultima» ma una fascia — il filo iniettato si propaga a molte dimensioni, e il protocollo lo
prende dal proxy più forte. Va bene così: quello che conta è che il filo si accenda.

## Il verdetto sui dati veri

| | ipotesi (una, dal primo 70%) | eccesso | verifica sul 30% | p | verdetto |
|---|---|---|---|---|---|
| **SE dal 2009** (2.817) | celle attaccate, più correlata | +2,75 | r +0,042 → tratto nuovo | **0,104** | non certificato |
| **EuroJackpot** (871) | **decine attaccate, MENO correlata** | **−3,32** | **r −0,126** contro +0,002 delle rimescolate | **0,025** | **CERTIFICATO** |

## Il rimbalzo della forma — cosa dice il certificato EJ

«Decine attaccate» è quanto compatta è l'estrazione sulle decine (la più lunga fila di decine
consecutive occupate). Anti-correlata nel tempo significa: **un'estrazione compatta tende a essere
seguita da una sparsa, e viceversa** — la forma rimbalza. E la dimensione è *context-free* (dipende
solo dall'estrazione stessa), quindi la parte meccanica delle finestre qui non c'entra nulla: sulle
rimescolate la correlazione è zero come dev'essere, sulla storia vera no.

Converge con un indizio **indipendente** della quarta tornata: la famiglia «forma rispetto
all'ultima» (somma, ampiezza) regge in `cerca` **solo sull'EuroJackpot**. Due strumenti diversi,
stessa direzione: sull'EJ la forma di un'estrazione e quella della successiva non sono estranee.

## La robustezza al taglio (aggiunta a fine sessione)

Stesso protocollo con lo scomparto spostato:

| taglio | ipotesi scelta sul primo tratto | verifica | p |
|---|---|---|---|
| 60% | **decine attaccate, meno correlata** (la stessa) | 348 estrazioni mai usate | **0,020** |
| 70% | **decine attaccate, meno correlata** | 261 | **0,025** |
| 80% | *attorno alla macchia di 10, più correlata* (un'altra) | 174 | 0,925 |

Lettura onesta: al 60% e al 70% la ricerca converge **sulla stessa ipotesi** e la verifica la
conferma due volte (i due tratti di verifica però si sovrappongono: non sono conferme
indipendenti). All'80% il blocco di ricerca sceglie un'ipotesi diversa, che si rivela spuria: con
137 dimensioni e segnali marginali la selezione non è stabile, e quel taglio **non ha mai messo
alla prova il rimbalzo** — non lo conferma né lo contraddice. Il quadro resta: certificato
marginale, coerente su due tagli, da rimisurare con l'archivio che cresce.

## I limiti, scritti subito

- Il tratto di verifica EJ è di **261 estrazioni**: p 0,025 è ≈2σ, un certificato **marginale**.
  Con due giochi provati (SE ed EJ), la probabilità di un falso positivo così da qualche parte è
  ~5%. Va **rimisurato a ogni crescita dell'archivio**: se è vero si rafforza, se era fortuna si
  spegne.
- Il SE, con un archivio tre volte più grande, non mostra niente di certificabile: se il rimbalzo
  fosse una proprietà generale delle estrazioni dovrebbe vedersi anche lì. O è una proprietà della
  macchina EJ, o è il 2,5% di sfortuna.
- Sotto la soglia di taratura (filo < 0,25 di equivalente) lo strumento è cieco: un «non
  certificato» non è un «non c'è».

## Le urne piccole

`filo jolly` / `filo superstar` / `filo euro` (stesso protocollo):

| urna | ipotesi dal primo 70% | p sulla verifica | verdetto |
|---|---|---|---|
| Jolly (4.242) | la colonna della schedina, meno correlata | 0,657 | non certificato |
| SuperStar (3.328) | metà del tabellone, meno correlata | 0,657 | non certificato |
| Euronumeri (455) | quanti lontani dalla macchia di 6, più correlata | **0,065** | non certificato, ma da riguardare |

L'Euronumeri sfiora la soglia — e sta sulla **stessa macchina dell'EuroJackpot**, l'unico gioco col
filo certificato. Con 455 estrazioni non si può dire di più: si rimisura quando l'urna cresce.

## Cosa se ne fa la catena

Niente da cambiare oggi: la catena **già usa** i B (è il suo meccanismo di correzione del tiro), e
le dimensioni restano tutte. Il certificato dice che sull'EJ quel meccanismo ha almeno un filo vero
da seguire. Se il rimbalzo regge alla crescita dell'archivio, il passo successivo è dargli più
peso in modo esplicito sull'EJ.
