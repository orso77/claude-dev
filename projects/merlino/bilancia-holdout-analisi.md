# Bilancia — il modello consolidato e la prima taratura con hold-out (2026-08-11)

Sessione nata da una richiesta esplicita dell'utente dopo l'esito nullo dell'estrazione del
15/04: *"crea un modello predittivo basato sulle estrazioni storiche, taralo in modo che sia
il più preciso possibile"*.

Storico al momento della run: **4.234 estrazioni**, 03/12/1997 → 08/08/2026.
Punti walk-forward valutabili: **4.034** (da minStart = 200), top-12, baseline urna onesta 0,800.

## Cosa è stato costruito

| File | Ruolo |
|------|-------|
| `BilanciaEngine.cs` | 9 canali consolidati, precalcolati in un tensore `[canale][punto][numero]` già z-normalizzato |
| `BilanciaTuner.cs` | Taratura con hold-out + distribuzione nulla + varianti a taratura ridotta |
| `Program.cs` | Modalità `Merlino.exe bilancia [repliche]` |

Bilancia **non inventa un paradigma nuovo**. Prende i canali che nelle sessioni precedenti si
erano piazzati meglio fra tutti quelli mai provati (Nexus, Oracle, Genesis, Mosaic, Quantum,
Segni, Ombra, Chronos) e li mette sulla stessa bilancia. La novità è tutta nel **protocollo di
misura**, che era l'ultimo TODO aperto del progetto.

### I nove canali

| # | Canale | Cosa guarda |
|---|--------|-------------|
| 0 | Peso | frequenza lunga con shrinkage — l'unico meccanismo fisicamente reale (bias/usura delle palline) |
| 1 | Caldo | densità di uscite nelle ultime 30 righe |
| 2 | Ritardo | righe trascorse dall'ultima uscita, saturato |
| 3 | Ritmo | vicinanza del ritardo corrente al proprio gap medio storico |
| 4 | Compagni | co-occorrenza in eccesso con i numeri dell'ultima estrazione |
| 5 | Successione | matrice di transizione fra estrazioni consecutive (Markov) |
| 6 | Riflesso | specchio 91−n, diametrale n+45, confinanti sulla ruota |
| 7 | Zodiaco | segno solare della data bersaglio (miglior canale isolato mai misurato nel progetto) |
| 8 | **Caso** | **controllo**: rumore puro deterministico |

Anti-leakage: lo stato incrementale al punto `t` riflette esattamente le righe `[0, t)`; la riga
`t` viene assorbita **dopo** il calcolo dei canali. L'unica cosa "futura" che entra è la **data**
della prossima estrazione (serve allo Zodiaco), nota dal calendario e non dall'esito.

Scelta implementativa che rende tutto il resto possibile: i canali sono precalcolati **una volta**
in un tensore. Valutare una configurazione di pesi diventa una sola combinazione lineare, quindi
si possono permettere 1.500 iterazioni di ricerca sia per il modello vero **sia per ogni replica
della distribuzione nulla**.

## Il protocollo (la parte che conta)

Lo storico è tagliato in due, una volta sola:

```
[200 .. 2822)    VALIDAZIONE  2.622 punti  — l'unica porzione che la ricerca vede
[2822 .. 4234)   TEST         1.412 punti  — mai vista durante la taratura
```

I pesi si scelgono massimizzando la validazione. La precisione dichiarata è quella sul **test**,
calcolata una volta sola sulla configurazione vincente.

In parallelo, 40 engine **completamente finti** (nove canali di rumore puro) passano per lo
stesso identico protocollo — stesse 1.500 iterazioni, stesso taglio, stessa scelta su
validazione, stessa misura su test. I loro punteggi di test formano la distribuzione nulla.

## Risultato 1 — la taratura non sopravvive al hold-out

| | E[centri] top-12 | scarto |
|---|---|---|
| Validazione (2.622 punti, dove i pesi sono stati scelti) | 0,8501 | **+6,3%** |
| **TEST (1.412 punti, mai visti)** | **0,7854** | **−1,8%** |

Stesso modello, stessi pesi: **+6,3% dove è stato tarato, −1,8% dove non lo è stato.**

Questa è la dimostrazione diretta, dentro un singolo esperimento, di ciò che `RumoreTest.cs`
aveva stabilito il 01/08 per via indiretta: il "+3-6%" celebrato in tutto il README del progetto
(+3,2% dei risultati onesti, +4,1% di Nexus, +3,6% di Oracle, +4,5% di Segni, +4,2% di Chronos)
**era selezione, non previsione**. Bilancia ne produce +6,3% in validazione, più di qualunque
engine precedente, e ne perde ogni traccia fuori campione.

Confronto col nullo:

| | valore |
|---|---|
| mediana dei 40 engine finti sul test | 0,8045 (+0,6%) |
| dev. standard del nullo | 0,0228 |
| minimo / massimo | 0,7472 / 0,8541 |
| **percentile di Bilancia** | **20,0%** |
| **p-value** | **0,805** |

Bilancia tarato è battuto da 4 engine finti su 5.

## Risultato 2 — più si tara, peggio va

Misurando sullo stesso test quattro varianti dello stesso modello, ordinate per quantità di
taratura:

| Variante | parametri liberi | E[centri] sul test | scarto |
|---|---|---|---|
| Argmax su 1.500 configurazioni | 9 | 0,7854 | −1,8% |
| Media dei 25 migliori per validazione | 9 (variance-ridotti) | 0,8173 | +2,2% |
| Pesi uguali, 9 canali | **0** | 0,7989 | −0,1% |
| **Pesi uguali, 8 canali (senza il Caso)** | **0** | **0,8293** | **+3,7%** |

La relazione è monotona nella direzione sbagliata: **la variante con zero parametri liberi batte
di 4,4 punti percentuali quella tarata con 1.500 iterazioni**. Il tuner non stava imparando, stava
memorizzando il rumore della validazione.

Corollario operativo: alla domanda *"taralo il più preciso possibile"*, la risposta misurata è
**non tararlo affatto**.

Le due varianti a pesi uguali non hanno parametri liberi, quindi non hanno alcun bias di
selezione e possono usare **tutti** i 4.034 punti (errore ±0,0127, il più stretto disponibile):

| | E[centri] | scarto | sigma |
|---|---|---|---|
| 9 canali a pesi uguali | 0,8116 | +1,5% | +0,91 σ |
| 8 canali a pesi uguali (senza il Caso) | 0,8183 | +2,3% | +1,44 σ |

+1,44σ ≈ p 0,075 a una coda, e la scelta fra le due varianti è essa stessa una micro-selezione
(2 opzioni): **non significativo**. Ma è l'unico numero del progetto che non sia strutturalmente
gonfiato.

## Risultato 3 — i canali da soli, la misura più sensibile del progetto

Un canale singolo non è scelto fra alternative: nessun bias di selezione, e può usare tutti i
4.034 punti. È la misura con la potenza statistica più alta mai fatta qui.

| Canale | E[centri] | scarto | sigma |
|---|---|---|---|
| Successione (Markov) | 0,8185 | +2,3% | **+1,46** |
| Riflesso (specchio/diametrale) | 0,8183 | +2,3% | +1,44 |
| Peso (bias palline) | 0,8173 | +2,2% | +1,36 |
| Zodiaco | 0,8171 | +2,1% | +1,34 |
| Compagni | 0,8044 | +0,6% | +0,35 |
| Ritardo | 0,8024 | +0,3% | +0,19 |
| Ritmo | 0,7972 | −0,3% | −0,22 |
| **Caso (rumore puro)** | **0,7938** | **−0,8%** | **−0,49** |
| Caldo | 0,7705 | −3,7% | **−2,32** |

Osservazioni:

- **Nessun canale raggiunge 2σ nella direzione giusta.** Provandone 9, il massimo atteso sotto
  rumore puro è ≈ +1,5σ: i quattro a +1,3/+1,5σ sono esattamente quello che il caso produce.
- I quattro canali di testa non sono indipendenti (Peso, Riflesso, Zodiaco e Successione
  condividono struttura), quindi non si sommano in evidenza.
- **Il "Caldo" è a −2,32σ**, la deviazione più grande di tutte, e va dalla parte sbagliata. È il
  pilastro di ogni sistema del lotto mai scritto (giocare i numeri caldi): sui 4.034 punti è
  l'unico canale che devia in modo apprezzabile, e devia *contro*.
- Il canale di controllo a −0,49σ conferma che la banda del rumore è dove ci si aspetta.

## Verdetto

Il modello richiesto è stato costruito e tarato con il protocollo più severo mai applicato nel
progetto. Il risultato:

1. La versione tarata **peggiora** fuori campione (−1,8%) ed è battuta dall'80% degli engine finti.
2. La versione migliore è quella **senza alcuna taratura** (+2,3% su tutto il campione, +1,44σ),
   che resta comunque non significativa.
3. Nessuno dei 9 canali, misurato senza selezione sul campione pieno, si distingue dal rumore.

Bilancia è quindi il decimo costrutto del progetto a finire dentro la banda del rumore, ma è il
primo a dirlo **dentro sé stesso**, con un numero fuori campione anziché con un confronto
esterno a posteriori.

## Nota operativa

`Merlino.exe bilancia [repliche]` (default 60). Con 40 repliche il run dura ~7 minuti; con 100
supera i 10 minuti perché ogni replica ripete l'intero protocollo di ricerca.

La giocata stampata esce dalla variante **a pesi uguali senza il Caso** (zero parametri liberi),
non da quella tarata; la giocata tarata è mostrata sotto solo per confronto.

Il percorso normale dell'app (`Merlino.exe` senza argomenti) resta invariato.

### Stima della data bersaglio — difetto corretto

La prima versione stimava la prossima estrazione come *ultima data + intervallo mediano delle
ultime 20*. Le estrazioni SE sono **martedì, giovedì, venerdì, sabato**: gli intervalli sono
3-2-1-1 e la loro mediana vale **2**. Partendo da sabato 08/08 il passo fisso di 2 giorni dava
10/08 → 12/08, **scavalcando martedì 11/08** che era il giorno reale dell'estrazione.

Corretto in `StimaProssimaData`: si raccolgono i giorni della settimana in cui si è estratto
nelle ultime 30 estrazioni e si cerca la prima data ≥ oggi che cada in uno di quei giorni.
Nessun effetto sui numeri predetti (11 e 12 agosto sono entrambi Leone, quindi il canale Zodiaco
non cambia), ma la data mostrata era sbagliata.

### Giocata per l'estrazione dell'11/08/2026

```
SEI NUMERI      06  49  62  79  81  83
DODICI NUMERI   01  06  40  49  54  55  62  79  81  83  85  86
```

(la variante tarata avrebbe detto `08 34 49 57 78 83`)

Distribuzione dei centri attesa, misurata sul test: 0 centri 41,9% — 1 centro 40,9% —
2 centri 14,0% — 3 centri 3,1% — 4 centri 0,07%.
