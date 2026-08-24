# Stato della sessione — 25/08/2026, notte

> ✅ **AGGIORNAMENTO 25/08/2026, giorno**: il passo successivo descritto in fondo (il protocollo a
> scomparto) e' stato **fatto**: vedi [scomparto.md](scomparto.md). Verdetto: nessuna fascia
> inclinata certificabile su SE dal 2009 ne' su EJ. Ai file non committati si aggiungono le
> modifiche a `Deriva.cs` e `Program.cs` (comando `scomparto`).

> Sessione interrotta dall'utente per riavvio. Questo file serve a riprendere da qui senza
> ricostruire niente.

## Dove sta il codice

**Sorgente**: `C:\src\orso\Merlino` — commit **`7fc13b8`** fatto **e pushato**.

**Non committato** (sul disco, compila, tutto funzionante):

| file | stato | cos'è |
|---|---|---|
| `Strategie.cs` | nuovo | `Merlino.exe strategie` — confronto delle strutture di gioco |
| `CercaSguardi.cs` | modificato | aggiunto `MERLINO_TUTTO=1` per l'elenco completo |
| `Locale.cs` | nuovo | `Merlino.exe locale [ampiezza]` — struttura locale nel tempo |
| `Deriva.cs` | nuovo | `Merlino.exe deriva [tutto\|ej] [blocco]` — le palline lungo il tempo |
| `Program.cs` | modificato | aggancio dei tre comandi nuovi |

Serve autorizzazione esplicita per committarli.

## Il punto di partenza della notte

Osservazione dell'utente, che era fondata: *«il tuo unico lavoro non è stato svilupparle ma
dimostrare matematicamente che sono infondate… ma nel caos non esiste solo la legge dei numeri»*.

Vera anche nel merito tecnico: **tutti i controlli fatti finora vivono dentro una sola lente**, la
media su tutta la storia. Il rimescolamento del tempo, la linearità del valore atteso, il fondo di
rumore — rispondono tutti alla domanda «vale *sempre*?». Una struttura che esiste **solo per un
tratto** viene cancellata da quelle misure per costruzione.

Da qui sono nati i due strumenti nuovi.

## `Merlino.exe locale` — la struttura che tiene adesso

Finestra scorrevole di W concorsi; per ogni dimensione si cerca il tratto di storia in cui si
comporta più diversamente dal proprio solito. Controllo: la stessa caccia su storie col tempo
rimescolato (che conserva le estrazioni e distrugge solo l'ordine).

| finestra | dimensioni che battono ogni controllo (su 121) | attese per caso |
|---|---|---|
| 40 | 1 | ~2 |
| 80 | 2 | ~2 |
| 150 | 2 | ~2 |
| 300 | 2 | ~2 |
| 600 | 4 | ~2 |

Con 60 controlli la soglia per caso è 121/61 ≈ 2. **Nessuna scala mostra più di quanto la ricerca
stessa produca.**

## `Merlino.exe deriva` — e la taratura che è il risultato vero della notte

Guarda le **palline** lungo il tempo, non le combinazioni: sovradispersione fra blocchi,
raggruppamento delle uscite, punto di rottura.

### Il controllo positivo, mai fatto prima in questo progetto

Prima di credere a un «non c'è», ho verificato che lo strumento veda **una cosa che c'è di sicuro**:
il cambio di macchina del 01/07/2009 (concorso 1425 su 4242).

**Prima versione: non lo vedeva.** Diagnosi — tagliava la storia a metà, e il cambio cade al 34%.
Un test che *assume* dove sta il salto non lo trova mai.

**Seconda versione (scansione di tutti i tagli, profilo dei 90 numeri): non lo vedeva lo stesso.**
Diagnosi, e questa è la parte che conta: il cambio 2009 vale **0,006** di distanza sul profilo per
singolo numero, contro un fondo di rumore di **0,05** alle taglie di campione disponibili. **Otto
volte sotto il rumore: non è rilevabile per principio**, non per difetto di strumento. Lo si era
trovato solo perché si guardava una *fascia* (79-90), che pooling dodici numeri alza il rapporto
segnale/rumore di √12.

**Terza versione — `RotturaSuFascia`: lo trova.** Scansione su 630 fasce × ~3.700 punti di rottura:

```
la fascia piu' inclinata e' 15-59, rottura al concorso 1291 (30%), a 4,02 scarti
                                            (il cambio vero e' al 1425, 34%)
```

Il punto stimato è giusto e la fascia è il complemento della coda alta. **Ma p = 0,23**: le storie
rimescolate, facendo la stessa caccia, raggiungono 4,02 scarti nel 23% dei casi.

### La lezione, che vale più di qualunque risultato

> Con uno spazio di ricerca di quella taglia, **anche un effetto fisico reale e certo non può essere
> certificato**. Lo strumento sa **localizzare** ma non sa **dimostrare**.

Questo cambia cosa si può chiedere ai dati: qualunque cosa trovata *cercando* è un'ipotesi, non un
risultato. Per certificarla serve o uno spazio di ricerca molto più piccolo (ipotesi dichiarata
prima), o dati non usati per trovarla.

## Cosa ha trovato sulla macchina attuale

| | fascia | rottura | scarti | p |
|---|---|---|---|---|
| **SuperEnalotto dal 2009** (2.817) | 74-78 | concorso 1989 (71%) | 3,64 | 0,54 |
| **EuroJackpot** (871) | 21-29 | concorso 621 (71%) | 2,35 | 0,98 |

Entrambi dentro il rumore della ricerca. Unica nota marginale: sull'EuroJackpot la
**sovradispersione** dà p = 0,075 — non significativa, ma è l'unico numero della notte che si
muova; con 871 concorsi il campione è piccolo e va riguardata quando cresce.

## ⏭️ Il passo successivo, già progettato e NON ancora fatto

**Il protocollo a scomparto**, che è l'unica strada per un risultato certificabile:

1. far girare `RotturaSuFascia` **solo sui concorsi fino a una certa data** (es. fino al 2022);
2. prendere **una sola** ipotesi: la fascia e il verso trovati lì;
3. verificarla sui concorsi **successivi**, che non sono stati usati per trovarla.

Così lo spazio di ricerca collassa a **una** prova invece che a due milioni, e il `p` torna a voler
dire qualcosa. È l'unico disegno che possa produrre un risultato vero — e, se non produce nulla,
produce un «non c'è» finalmente solido.

Serve aggiungere a `Deriva.cs` un parametro di taglio della storia e un secondo passaggio di sola
verifica.

## Nota pratica

Lo stato della catena sul disco potrebbe contenere l'ultimo cammino di controllo. Se i numeri
devono essere quelli veri, cancellare `data\osservatore\catena-superenalotto.txt` prima di
`Merlino.exe giocata`.
