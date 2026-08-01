# Segni, Ombra, Forma, Chronos — quattro tentativi inventati e il loro esito (2026-08-01)

Sessione nata da una richiesta esplicita: **smettere di usare teorie prese in prestito**
(quantum walk, Hopfield, Fourier, cristallografia, vortici) e **inventare da zero**
costrutti nati guardando questo oggetto, seguendo il metodo dell'utente:
*osservare → inventarsi un pattern → provare a seguirlo*.

Storico al momento della run: **4.229 estrazioni**, 03/12/1997 → 31/07/2026.
Tutte le misure su **4.029 punti di walk-forward**, top-12, baseline random 0,800.

## Cosa è stato costruito

| File | Costrutto | Origine |
|------|-----------|---------|
| `FormaAnalysis.cs` | Teoria della Forma | inventata qui |
| `SimboliEngine.cs` | Teoria dei Segni | inventata qui |
| `OmbraEngine.cs` | Ombra / Testimoni / Muta | inventati qui |
| `ChronosEngine.cs` + `ChronosTuner.cs` | Debito / Memoria lunga / Ciclo | inventati qui |
| `WalkTuner.cs` | tuner walk-forward generico riusabile | infrastruttura |

Modalità da riga di comando (il percorso normale dell'app resta invariato, ~1 minuto):

```
Merlino.exe forma      Merlino.exe simboli
Merlino.exe ombra      Merlino.exe chronos
```

Tutti gli engine nuovi hanno **pesi firmati** (il tuner può assegnare peso negativo a
un canale, cioè scoprire che va letto al contrario) e un **canale di controllo "Caso"**
fatto di rumore puro deterministico. Il canale Caso è lo strumento diagnostico centrale.

## 1. Teoria della Forma

**Idea**: lo spazio delle combinazioni ha 622.614.630 punti e ne abbiamo osservati 4.229
(lo 0,00068%): siamo ciechi. Ma una sestina ha una *forma* — somma, ampiezza, decine
coperte, pari/dispari, coppie consecutive, distanza minima — e lo spazio delle forme ha
poche centinaia di punti. L'aggregazione compra potenza statistica.

Sotto urna onesta la distribuzione di ogni descrittore è **calcolabile esattamente**
(nessuna simulazione): ipergeometrica per i pari, `C(k-1,r)·C(n-k+1,k-r)` per le coppie
consecutive, inclusione-esclusione per le decine, `(k-w)·C(w-1,4)` per l'ampiezza,
`C(k-(d-1)(g-1),d)` per la distanza minima, DP per la somma.

**Esito**: nessuna deviazione.

| Descrittore | chi² | df | p-value |
|---|---|---|---|
| Numeri pari | 5,37 | 6 | 0,498 |
| Coppie consecutive | 8,49 | 3 | 0,037 |
| Decine coperte | 1,54 | 4 | 0,819 |
| Ampiezza (max−min) | 68,10 | 66 | 0,406 |
| Distanza minima | 7,33 | 11 | 0,772 |
| Somma | 284,45 | 268 | 0,234 |

1 descrittore su 6 sotto p<0,05, contro 0,3 attesi per solo caso; soglia Bonferroni
p<0,0083. Le coppie consecutive a p=0,037 **non** superano la soglia.

Conclusione: nello spazio dove avremmo avuto la potenza statistica per vedere una firma,
la forma delle estrazioni è indistinguibile da quella di un'urna perfetta.

## 2. Teoria dei Segni

Sei canali simbolici, nessuno matematico: **Luna** (fase lunare della data), **Zodiaco**
(segno solare), **Pianeta** (giorno della settimana), **Smorfia** (13 famiglie simboliche
napoletane: se esce un numero, i parenti simbolici si accendono), **Trasformazioni**
(specchio 91−n, rovescio, diametrale n+45, gemelli, consecutivi), **Caso**.

Nota anti-leakage: la data della prossima estrazione è nota in anticipo, quindi
condizionare su luna/zodiaco/pianeta del giorno bersaglio è lecito — si usa il
calendario, non l'esito.

**Esito combinato: E[centri] = 0,8357 (+4,5%)** — nominalmente il **miglior valore atteso
mai ottenuto in questo progetto**, sopra Nexus (0,833). P(≥3) = 3,67%, praticamente pari
al record di Quantum (3,68%).

Ma i canali isolati raccontano un'altra storia:

| Segno da solo | E[centri] | scarto |
|---|---|---|
| Zodiaco | 0,8146 | +1,8% |
| Trasformazioni | 0,8094 | +1,2% |
| Luna | 0,8084 | +1,0% |
| **Caso** | **0,8076** | **+1,0%** |
| Pianeta | 0,8019 | +0,2% |
| Smorfia | 0,7808 | −2,4% |

Il **rumore puro fa esattamente quanto la Luna** e meglio del Pianeta. E nella
combinazione vincente il tuner ha dato al Caso peso −0,627, dello stesso ordine dei
segni veri: se i segni portassero informazione, il rumore sarebbe stato spinto a zero.

## 3. Ombra / Testimoni / Muta

Tre costrutti inventati per questo oggetto:

- **Ombra** — ogni estrazione lascia 6 punti e 7 vuoti sulla ruota; il vuoto più grande ha
  centro e larghezza. Tesi: l'ombra non salta, *scivola*, ha inerzia. Si stima la deriva
  del centro, si proietta, e si giocano i numeri sul **bordo** dell'ombra prevista
  penalizzando il suo cuore.
- **Testimoni** — ogni numero si è costruito in 29 anni una compagnia (co-presenze in
  eccesso). Tesi: un numero è *chiamato* quando la sua compagnia si muove senza di lui.
- **Muta** — aderenza fra estrazioni consecutive (quanti numeri restano entro distanza d
  dai precedenti). Tesi: c'è un respiro fra "aggrapparsi" e "cambiare pelle", prevedibile.

**Esito combinato: 0,8243 (+3,0%)**, P(≥3) 2,98% (sotto il random ~3,3%).

| Costrutto da solo | E[centri] | scarto |
|---|---|---|
| Testimoni | 0,8014 | +0,2% |
| Caso | 0,7997 | −0,0% |
| Ombra | 0,7937 | −0,8% |
| Muta | 0,7816 | −2,3% |

Nessuno dei tre batte il rumore. Il tuner ha dato al Caso peso −0,923, il **più alto in
valore assoluto dopo i Testimoni**.

## 4. Chronos — Debito / Memoria lunga / Ciclo

Costruito su richiesta di usare *tutto* lo storico dal 1997. Tre canali: **Debito** (scarto
dalla quota attesa dall'origine, in deviazioni standard), **Memoria lunga** (somma pesata
di tutte le apparizioni con decadimento continuo), **Ciclo** (periodo dominante di ciascun
numero come eccesso in z-score sopra l'attesa geometrica dei gap, più allineamento di fase).

**Esito combinato: 0,8340 (+4,2%)**, P(≥3) 3,30% (= random).

| Canale da solo | E[centri] | scarto |
|---|---|---|
| Debito | 0,8022 | +0,3% |
| Ciclo | 0,7990 | −0,1% |
| Memoria lunga | 0,7769 | −2,9% |
| Caso | 0,7729 | −3,4% |

Il tuner ha dato peso **negativo** sia al Debito (−0,531) sia alla Memoria (−0,485): cioè
ha trovato che conviene fare l'opposto della compensazione. Il Ciclo ha ricevuto peso
+0,011, cioè **è stato spento**.

## Il conto statistico che chiude tutto

Con 4.029 punti di test, top-12, la deviazione standard della media dei centri è

```
Var(centri) = 12 · (6/90) · (84/90) · (78/89) = 0,6544
sd(media)   = sqrt(0,6544 / 4029) = 0,0127
```

Quindi ogni canale isolato, in sigma:

| Canale | scarto | sigma |
|---|---|---|
| Zodiaco | +0,0146 | +1,15 σ |
| Trasformazioni | +0,0094 | +0,74 σ |
| Luna | +0,0084 | +0,66 σ |
| **Caso (Segni)** | **+0,0076** | **+0,60 σ** |
| Debito | +0,0022 | +0,17 σ |
| Pianeta | +0,0019 | +0,15 σ |
| Testimoni | +0,0014 | +0,11 σ |
| Caso (Ombra) | −0,0003 | −0,02 σ |
| Ciclo | −0,0010 | −0,08 σ |
| Ombra | −0,0063 | −0,49 σ |
| Muta | −0,0184 | −1,44 σ |
| Smorfia | −0,0192 | −1,51 σ |
| Memoria lunga | −0,0231 | −1,81 σ |
| **Caso (Chronos)** | **−0,0271** | **−2,13 σ** |

**Il fatto decisivo**: i tre canali "Caso" sono rumore puro per costruzione, e sono
finiti a +0,60σ, −0,02σ e −2,13σ. Quella forbice di 2,7σ **è** la banda del rumore su
questo campione. Ogni singolo costrutto inventato — luna, zodiaco, smorfia, ombra,
testimoni, muta, debito, ciclo — cade **dentro** quella banda.

E i risultati combinati (+4,5%, +4,2%, +3,0%) sono spiegati interamente dalla selezione:
scegliendo il massimo fra ~112 configurazioni valutate, il massimo atteso del rumore è
≈ 2,6–2,8σ ≈ +0,034. Simboli ha fatto +0,0357, Chronos +0,0340. **Esattamente il massimo
del rumore, non un dito sopra.**

## Convergenza fra i tre engine (previsione 01/08/2026)

| Engine | Top-12 |
|---|---|
| Segni | 02 04 05 08 37 49 55 65 74 77 81 84 |
| Ombra | 09 10 19 20 31 40 43 47 67 69 76 79 |
| Chronos | 32 38 41 45 54 65 72 77 80 86 88 90 |

Su 36 caselle, i numeri condivisi da almeno due engine sono **due**: il **65** e il **77**
(Segni + Chronos). Ombra non condivide nulla con nessuno. Tre costrutti che guardassero
davvero la stessa struttura sottostante concorderebbero molto di più.

## Verdetto

Il metodo dell'utente — *osservare, inventare, seguire* — è stato applicato integralmente
e con costrutti mai pubblicati da nessuno. Il passo "seguire" è quello che ha risposto:
nessuno degli otto costrutti inventati si distingue dal rumore che gli gira accanto nello
stesso identico esperimento.

Questo non è un limite di fantasia: la fantasia c'è stata (l'ombra che scivola, i numeri
chiamati dalla propria compagnia, la ruota che cambia pelle, i segni del calendario). È
che il canale di controllo ha vinto o pareggiato ogni volta.

Il valore residuo del lavoro è **diagnostico**: da adesso ogni futuro costrutto può essere
misurato contro un rumore costruito nello stesso esperimento, e il confronto è immediato.
`WalkTuner.cs` rende la cosa riusabile in poche righe per qualsiasi nuova idea.

## Nota tecnica

Nessuna modifica al percorso normale dell'app: `Merlino.exe` senza argomenti fa esattamente
quello che faceva prima (fetch SE + EJ, InstinctEngine, giocata 6+1 e 5+2, ~1 minuto).
Le quattro modalità nuove sono attivate solo da argomento esplicito.
