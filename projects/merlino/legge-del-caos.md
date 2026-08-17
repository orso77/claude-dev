# La legge del caos — lo sciame di osservatori

> Lavoro del 17/08/2026. Motto del progetto, dettato dall'utente:
> **«trovare la legge del caos e predirlo»**.
>
> Stato: motore costruito e in primo cammino. **Risultato non ancora acquisito** — la sezione
> «Esito» va compilata quando `Merlino.exe caos` termina.

## Da dove nasce

Sessione partita da tre osservazioni dell'utente sull'output del modello grafico, in ordine:

1. *«non mi piace la predizione»* → la giocata era `01 09 18 19 22 90`
2. *«non mi piace, 5 numeri sotto a 22»* → **il difetto vero**
3. *«cambia l'occhio e correggi»*

Poi la richiesta si è allargata a un impianto teorico completo, riportato qui sotto con le parole
dell'utente perché è la specifica del motore.

## La teoria, come l'ha formulata l'utente

> «La teoria del caos per come la intendiamo noi è una sovrapposizione di vettori multidimensionali
> da infiniti osservatori. Gli osservatori si generano ad ogni singola successiva osservazione. Più
> estrazioni ci sono più osservatori si creano. Ogni osservatore fa un'osservazione multidimensionale
> che poi convogliano tutte in un motore multivettoriale che le pesa e genera pattern previsionali
> del caos.»

I quattro stadi, sempre parole sue:

1. creazione degli osservatori (gli occhi) analizzando le estrazioni
2. analisi delle estrazioni da parte di tutti gli osservatori
3. creazione di pattern basati sulle osservazioni multidimensionali dei singoli osservatori,
   verticalizzate
4. algoritmo incrementale di predizione

Vincoli aggiuntivi dati durante la costruzione, tutti recepiti:

- **niente costanti, solo variabili mutevoli in quantità e valore**
- **gli occhi non muoiono mai**: cambia il loro peso, non la loro esistenza — «diversamente avremmo
  sempre e solo un punto di vista vincente, e non è così»
- **gli occhi sono N, mai definiti**; l'osservazione ha infiniti punti di vista
- l'alfabeto deve contenere **frequenze, ritardi, decine, min, max, consequenzialità**
- **si possono aggiungere occhi nel tempo**
- **le estrazioni storiche sono costanti note**: non si può riattraversare tutto a ogni previsione,
  serve salvare lo stato e aggiungere solo le estrazioni nuove

## Perché è una domanda nuova per questo progetto

Tutti i motori precedenti — Nexus, Oracle, Genesis, la griglia grafica — avevano **un insieme fisso
di caratteristiche e pesi statici**, trovati una volta sola guardando tutta la storia in blocco.
Cercavano una legge valida *sempre*.

Questo cerca una struttura valida *adesso*, e non le chiede di durare: le chiede di durare un passo.
È l'unica famiglia di ipotesi che il banco di prova esistente non poteva né confermare né smentire,
perché misura modelli statici.

**Non è una scappatoia dal risultato nullo**: è una classe di modelli diversa. Che poi il risultato
resti nullo è possibile e va misurato, non assunto.

## Architettura — `CaosEngine.cs`

### L'alfabeto (14 letture elementari)

Non sono punti di vista, sono modi di posare l'occhio. Nessuno esprime un'ipotesi.

| # | lettura | # | lettura |
|---|---|---|---|
| 0 | da quanto è fermo (ritardo) | 7 | pari o dispari |
| 1 | quanto è uscito di recente (frequenza) | 8 | dove sta sulla schedina |
| 2 | quanto è uscita la sua fascia (decina) | 9 | da quanto è fermo il suo vicino |
| 3 | quanto è uscita la sua riga | 10 | quanto è uscito il dirimpettaio |
| 4 | quanto è uscita la sua colonna | 11 | quanto è vicino al più basso (min) |
| 5 | con chi si accompagna | 12 | quanto è vicino al più alto (max) |
| 6 | quanto è vicino sulla tela | 13 | quanto segue un numero uscito (consequenzialità) |

L'alfabeto è **aperto**: una voce in più non aggiunge un punto di vista, li **moltiplica** tutti,
perché entra in ogni intreccio con le altre su ogni finestra e in ogni verso.

### Dall'alfabeto agli osservatori

- **Direzione** = una lettura, su una *finestra* di memoria, guardata in un *verso*
  (`molto` / `poco` / `come adesso`) con una *nitidezza*.
  Il `come adesso` non ha soglia: guarda il valore **tipico del momento**, cioè quello dei numeri che
  stanno uscendo, quindi si sposta con la storia.
- **Osservatore** = un **intreccio** di 1..5 direzioni. Si moltiplicano, non si sommano: un numero si
  accende solo se regge lungo *tutte* le direzioni insieme. È questo che rende il punto di vista
  multidimensionale — guarda uno spigolo dello spazio, non una faccia.

Nessun osservatore è scritto nel sorgente. Nascono attraversando la storia.

### La verticalizzazione

La forza di un numero **non** è la somma delle voci:

```
forza[n] = voce[n] × (quanti sguardi DISTINTI lo accendono)
```

Un numero acceso da molti occhi che guardano cose **diverse** è una costante osservata da più punti
di vista. Un numero acceso da molti occhi che guardano la stessa cosa è un'**eco**: lo stesso
frammento contato più volte. Le proiezioni che si sovrappongono da direzioni diverse ricostruiscono
una forma, quelle parallele no.

### Le dinamiche

- **Nessuna morte.** Il peso di un occhio si aggiorna come `peso = peso × oblio + (colpi − dovuti)`,
  dove `dovuti` è quanto prenderebbe per la sola estensione della sua macchia. Chi non tiene arriva a
  peso nullo, **resta nello sciame** e continua a essere interrogato: se quello che guardava torna a
  valere, torna a contare.
- **Crescita pari alla storia.** A ogni estrazione nasce un occhio: figlio di uno che sta tenendo
  (con memoria, ampiezza, verso, nitidezza e **profondità** mutati) oppure una parola nuova di zecca.
- **Nessun parametro fisso.** Memoria, ampiezza, profondità, verso, nitidezza, oblio: tutti per
  osservatore e tutti mutevoli.

### La predizione incrementale

`Salva` / `Riprendi` in `data/caos/sciame-{gioco}.txt`: ogni occhio con le sue direzioni e il suo
peso, più quante estrazioni ha già attraversato. Alla partenza successiva lo sciame riprende e
attraversa **solo le estrazioni nuove**. Il cammino completo si paga una volta.

Il file si rifiuta di essere ripreso se l'alfabeto è cresciuto o se cambia il gioco: gli occhi
vecchi guarderebbero cose diverse da quelle con cui si erano formati.

## Il controllo — l'unica cosa che può dire di no

Un sistema che si adatta **trova sempre qualcosa da dire**, anche dove non c'è niente da vedere: gli
occhi che pesano di più sono quelli che hanno azzeccato, e pesano di più anche se hanno azzeccato per
caso. È la trappola in cui questo progetto è già caduto otto volte.

Perciò lo stesso sciame cammina anche sulle **stesse estrazioni con l'ordine del tempo mescolato**.
Lì una legge del caos non può esserci, perché non esiste più un prima e un dopo. Se lo sciame arriva
altrettanto in alto, quello che vede se lo sta facendo da solo.

Criterio: dei `quanti` numeri usciti, quanti erano fra i `quanti` dello sciame. Sei su novanta ne
prendono 0,40 per la sola estensione.

## Esito

Due impianti costruiti e misurati, entrambi col controllo del tempo mescolato.

### Impianto A — sguardi sorteggiati (`CaosEngine`, `Merlino.exe caos`)

4.262 osservatori, 2.614 che tengono, 10,3 minuti di cammino.

| | peggiore | media | migliore |
|---|---|---|---|
| storia vera | 0,975x | **1,004x** | 1,033x |
| tempo mescolato | 0,992x | **1,006x** | 1,020x |

### Impianto B — esaustivo, zero sorteggi (`CaosSciame`, `Merlino.exe sfera`)

4.235 osservatori (uno per estrazione), 2.154 che tengono, 25,8 minuti.

| cammino | colpi | guadagno |
|---|---|---|
| **storia vera** | 0,399 | **0,997x** |
| tempo mescolato 1 | 0,441 | 1,103x |
| tempo mescolato 2 | 0,431 | 1,078x |
| tempo mescolato 3 | 0,415 | 1,037x |

**La storia vera sta sotto tutti e tre i controlli.** L'impianto B non ha né sorteggi né manopole —
è interamente determinato dalle estrazioni passate — quindi non c'è niente da ritarare e il numero
è definitivo per questa architettura.

**Nono risultato nullo del progetto**, il primo però ottenuto con un modello che non cerca una legge
invariante ma una struttura transitoria. La classe di ipotesi era davvero nuova; l'esito no.

## Il difetto di forma, e la correzione fatta dagli osservatori

Segnalazione dell'utente sulla previsione dell'impianto A — `53 57 60 61 62 63`: *«non credo ci sia
mai stata un'estrazione così, quindi non è storia, è una deduzione basata su osservatori non
attendibili»*. **Terza volta che questa intuizione trova un difetto vero.** Misurato sui dati:

| tutti e sei dentro un arco di… | volte su 4.237 |
|---|---|
| **10** (la giocata dello sciame) | **0 — mai** |
| 15 | **0 — mai** |
| 20 | 4 (0,09%) |
| 30 | 65 (1,5%) |

La figura più stretta mai uscita in 29 anni: **28/09/2006 → `52 58 61 62 65 69`, arco 17**.

**Causa**: prendere i sei punti più alti di un campo convergente significa prendere sei punti della
stessa collina. È lo stesso difetto già corretto nel modello grafico con le vette, in forma più
grave perché lo sciame converge più del disegno.

**Correzione — e chi l'ha fatta.** Obiezione decisiva dell'utente: *«queste osservazioni le devono
fare gli osservatori, non io, non tu»*. Ed era vero: tre difetti su tre trovati dall'utente, con me
che scrivevo a mano il controllo e sceglievo io cosa l'Occhio dovesse guardare.

Gli osservatori **avevano già il dato**: ognuno ha visto passare migliaia di estrazioni vere e
nessuna gli è mai sembrata luminosa al massimo. Bastava chiederglielo. Quindi ogni osservatore ora
ricorda **quante volte ha visto ciascuna luminosità** e la giocata non è più il massimo: è la figura
che ha riscontro nella loro memoria, moltiplicata per la convergenza.

Precisazione dell'utente, recepita: il criterio **non** è «è già uscita» — nessuna sestina esce due
volte, quel criterio rifiuterebbe tutto — ma **la plausibilità rispetto alla memoria di tutti gli
osservatori precedenti**. Da qui la **catena**: ogni osservatore eredita stime e memoria da quello
prima, ci aggiunge il suo sguardo, e le passa a chi nasce dopo. Senza eredità un osservatore appena
nato non ha visto niente e non può giudicare proprio quando serve.

Effetto misurato:

| | figura | riscontro |
|---|---|---|
| dove converge lo sciame, nudo | `79 81 83 85 87 89` | 3,7% |
| **la giocata scelta dai testimoni** | `03 07 11 13 85 89` | **19,9%** |

La convergenza nuda aveva prodotto di nuovo una figura degenere (tutti dispari, tutti nelle ultime
due righe). I testimoni l'hanno scartata da soli.

**Attenzione a non confondere le due cose**: la correzione agisce sulla FORMA, non sulla resa. Lo
sciame resta a 0,997x. Un modello inutile ma onesto è meglio di uno inutile e storto, perché il
secondo fa credere di vedere qualcosa.

## La riprogettazione delle dimensioni (17/08/2026, sera)

Il difetto di forma è tornato **sei volte** in una giornata — `53 57 60 61 62 63`, `08 33 81 83 87
89`, `79 81 83 85 87 89`, `07 79 81 83 85 89` — sempre segnalato dall'utente a occhio nudo. Diagnosi
sua, ed è quella giusta:

> «È un modo di osservare errato e quindi di predire errato. La predizione è errata perché
> l'osservazione è insufficiente.»

**Causa strutturale**: tutte le dimensioni chiedevano *«che cosa so di questo numero?»*. Nessuna
chiedeva *«che cosa è questa figura?»*. Ma dall'urna escono sei numeri **insieme**: un apparato che
osserva solo numeri singoli produce sei numeri singoli ottimi che formano una figura impossibile.
L'oggetto da prevedere non era mai stato osservato.

### Due famiglie invece di una

**A — del numero** (11): ritardo, frequenza, **ritmo** (il ritardo di adesso contro quello abituale
*di quel numero*), compagnia, vicini, decina, riga, colonna, vicinanza sulla tela, parità, popolarità.

**B — della figura** (12): quante decine occupa, massimo in una decina, massimo in due decine
attaccate, ampiezza, ampiezza tolto il più staccato, irregolarità dei passi, coppie di consecutivi,
quanti pari, somma, dove cade il minimo, dove cade il massimo, celle attaccate.

**Rimosse**: *dirimpettaio sulla tela* (simmetria inventata), *dove sta sulla schedina*, *vicinanza al
minimo/massimo* — queste ultime erano proprietà della figura travestite da proprietà del numero.

### La costruzione rovesciata

Non più «ordina i 90 e prendi i primi sei»: si cerca la sestina che sta in alto secondo A **ed è
fatta come le estrazioni vere** secondo B, con ricerca a scambi su **tutti e 90** invece che dentro
un ventaglio di 18 — quel ventaglio era ritagliato dalla collina, quindi nessuna scelta lì dentro
poteva essere sparsa.

Il giudizio di forma è la **media geometrica** delle dodici risposte: una figura che sbaglia *una*
cosa in modo grave sprofonda invece di diluirsi. Due versioni precedenti erano sbagliate ed è utile
ricordarle: il *minimo* sui tratti bocciava perfino le estrazioni vere (tutto a 0,00%); la *frazione
di tratti già visti* era troppo indulgente (un difetto mortale costava 1/42, e `07 79 81 83 85 89`
passava al 96,9%).

### La catena legge l'errore

Ogni anello riceve la predizione del precedente, calcola **mancati** (usciti non predetti) e
**falsi** (predetti non usciti), e si chiede su quali assi si era fatto ingannare: la correzione
spinge nella direzione che avrebbe alzato i mancati e abbassato i falsi. Prima il criterio era una
classifica generale (`suUsciti − suTutti`); adesso è l'errore della giocata effettivamente fatta,
attribuito a chi l'ha causato.

### Il difetto della pesatura, trovato dall'utente a occhio nudo

```
Stima = Stima * oblio + incremento              ← sbagliato
Stima = Stima * oblio + (1 - oblio) * incremento ← corretto
```

Mancava `(1 − oblio)`. Con memoria di 4.000 estrazioni l'oblio vale 0,99975: ogni incremento restava
dentro per quattromila giri e si sommava, quindi non pesava chi teneva ma **chi aveva camminato a
caso più in alto**. Sintomo visibile: «pari o dispari» a **472.977** contro 5,91 di un altro asse, e
una previsione fatta di sei numeri tutti dispari. Dopo il fix gli stessi pesi stanno fra −0,76 e 0,06.

### Esito — la forma è risolta

Previsione: **`13 27 29 68 79 86`** — cinque decine diverse, mai più di due nella stessa, ampiezza 73.
Ogni tratto cade dove cadono le estrazioni vere. La convergenza nuda dava `13 27 28 29 79 86`
(forma 17,2%), i testimoni hanno scambiato il 28 con il 68 → **forma 36,0%**.

Giudizio sulle figure segnalate dall'utente, con il tratto che le affonda **individuato dal sistema**:

| figura | riscontro | tratto che l'affonda |
|---|---|---|
| `01 02 03 04 05 06` | **0,09%** | occupa 1 decina — mai visto in 29 anni |
| `01 03 05 07 09 11` | **0,48%** | somma in quella fascia — mai vista |
| `02 04 06 08 10 12` | **0,47%** | idem |
| `05 10 15 20 25 30` | **6,38%** | il più alto cade nella 3ª decina — 0,05% |
| `81 83 85 87 88 90` | **0,36%** | occupa 1 decina — mai visto |
| `01 18 30 47 62 85` (qualunque) | 25,25% | — |
| `18 24 69 71 73 82` (ultima vera) | **29,03%** | — |

`05 10 15 20 25 30` prima passava al 94%: il sistema ha trovato da solo che il suo difetto non è il
passo regolare ma il massimo troppo basso.

### Esito — la resa non è risolta

| cammino | guadagno |
|---|---|
| **storia vera** | **1,066x** |
| tempo mescolato | 1,091x · 1,056x · 1,003x |

Dentro le acque del disordine, come tutto il resto.

### Il riscontro storico — 800 estrazioni ripredette una per una

| centrati | volte | quota | atteso a caso |
|---|---|---|---|
| 0 | 511 | 63,88% | 65,29% |
| 1 | 240 | 30,00% | 29,75% |
| 2 | 46 | **5,75%** | 4,65% |
| 3 | 3 | 0,38% | 0,31% |
| 4, 5, 6 | **0** | — | 0,03% |

L'unico scostamento visibile è sui «due centrati»: 46 contro i 37,2 attesi, cioè **1,5 volte
l'errore tipico** (5,96). Non è niente. Quattro centrati mai, in 800 tentativi.

### La taratura delle dimensioni (`Merlino.exe taratura`)

Spento un asse per volta, blocco di scelta e blocco di conferma separati, e le stesse dodici
varianti in parallelo su una storia col tempo mescolato.

| | scelta | conferma |
|---|---|---|
| migliore sulla **storia vera** | 1,026x | 1,129x |
| migliore sul **tempo mescolato** | **1,072x** | **1,139x** |

La classifica si **ribalta** fra i due blocchi: `tutte le dimensioni` è la peggiore in scelta
(0,940x) e la migliore in conferma (1,129x); `senza colonna` fa l'opposto. È la firma del rumore.
E la migliore fra dodici varianti spicca **di più** sul disordine che sulla storia vera: il guadagno
apparente è tutto effetto dell'aver scelto il massimo fra dodici.

**Conclusione**: nessuna configurazione da preferire. Si tengono tutte le dimensioni accese — che è
anche l'unica scelta che non richiede di aver scelto.

### Falso positivo evitato — i pari merito nella posizione media (18/08/2026)

Al primo giro il righello fine dava **posizione media 41,92 contro un neutro di 45,50**: nove volte
l'errore tipico, cioè una scoperta. Era un difetto di conteggio: i numeri con forza identica —
tipicamente zero, perché nessun osservatore che pesa li accende — venivano messi tutti in cima al
loro gruppo invece che a metà. I numeri usciti cadono quasi sempre in quel mucchio, quindi la media
scendeva da sola.

Con il conteggio corretto (`sopra + (uguali + 1) / 2`): **45,23–45,81 contro 45,50**, cioè nulla.

**Nona occorrenza della stessa forma di errore in questo progetto — la prima trovata prima di
annunciare il risultato invece che dopo.**

### La forma nel tempo — `Merlino.exe forma` (18/08/2026)

**Il ragionamento**: all'urna abbiamo sempre fatto la domanda più difficile che esista — *quali sei
numeri* — che ha 29 bit di incertezza e ci affoga dentro qualunque segnale debole. La forma invece
è una domanda molto più piccola: *quante decine occuperà* è un valore fra 2 e 6, meno di due bit. Se
il processo ha una memoria qualsiasi, si manifesta lì **quindici volte più visibilmente**.

E non era mai stato chiesto: la forma è stata misurata, giudicata e corretta tutto il giorno, ma
sempre come *descrizione*, mai come *cosa da prevedere*.

12 tratti × 5 distanze (−1, −2, −3, −5, −10) + 144 coppie incrociate, con soglia presa sul
**massimo di 40 copie della storia col tempo mescolato**.

| | |
|---|---|
| caselle sopra soglia, attese per puro caso | ~1,5 (60 caselle, soglia = max di 40 copie → 1/41 ciascuna) |
| caselle sopra soglia, osservate | **3**, a distanze scoordinate (−10, −2, −10) |
| coppie incrociate sopra soglia su 144 | **0** |

**La forma di ieri non dice niente sulla forma di oggi.**

### I ritorni — il test più diretto di memoria che esista

Se la macchina avesse una memoria qualunque — palline non rimescolate del tutto, un residuo — si
vedrebbe qui prima che altrove: **quanti numeri tornano** da un'estrazione alla successiva. Non è un
modello, è il contatto fisico diretto fra due estrazioni, e l'attesa è esatta (ipergeometrica).

| distanza | ritorni medi | atteso | scarto in errori |
|---|---|---|---|
| −1 | 0,3918 | 0,4000 | **−0,90** |
| −2 | 0,3940 | 0,4000 | −0,66 |
| −3 | 0,3946 | 0,4000 | −0,60 |
| −5 | 0,3914 | 0,4000 | −0,94 |
| −10 | 0,4061 | 0,4000 | +0,67 |
| −20 | 0,4018 | 0,4000 | +0,20 |

Tutto entro un errore tipico. Su EuroJackpot la distanza −5 segna 2,49 errori, ma su 12 prove
complessive è atteso.

**Questo è il risultato più forte della giornata, e va letto per quello che è**: non «non abbiamo
trovato la memoria», ma **«la memoria dell'urna, se c'è, è più piccola di 0,008 palline su sei»**.
È la conversione di un fallimento in una misura.

### Il limite del righello (da tenere presente)

Il criterio «quanti dei 6 usciti stanno fra i 6 scelti» ha una **risoluzione dell'8%**: media attesa
0,400 con scarto 0,594, su 1.500 estrazioni l'errore sulla media è 0,0153 → 3,8% in rapporto, due
scarti 7,7%. I controlli col tempo mescolato si sparpagliano esattamente di quell'ampiezza
(1,003–1,091), che è la conferma. Dire «dentro le bande» significa solo **«niente più grande
dell'8%»**, mentre un effetto reale in una lotteria sarebbe dell'1–3%.

**TODO aperto**: affiancare la *posizione media in classifica* dei 6 usciti fra tutti e 90 (attesa
45,5, errore 0,27 su 1.500 estrazioni) — da tre a cinque volte più sensibile, sugli stessi dati.

### Strade chiuse, da non riproporre

- **Sbilanciamento fisico dell'urna**: già provato, `bilancia-holdout-analisi.md` → chi² = 99,2 con
  df = 89, **p ≈ 0,22**, compatibile con un'urna onesta. Il canale `Peso` che lo codificava è stato
  rimosso perché adattava rumore (fuori campione 0,8293 → 0,8286: nessuna perdita).
- **Popolarità come criterio di scelta**: esclusa dall'utente. Resta come *dimensione* da verificare,
  e si è guadagnata peso **0,02** — praticamente nulla. Risposta empirica, non decisa a tavolino.

## Tempi — vincolo dell'utente: max 60 secondi per avvio

Rispettato e **cronometrato**, non promesso:

| | primo cammino (una volta) | avvio incrementale |
|---|---|---|
| SuperEnalotto | 15,7 minuti | **0,8 secondi** |
| EuroJackpot + SuperStar + Euro numeri | inclusi | < 1 secondo |

Lo sciame si salva in `data/caos/sfera-{gioco}.txt` (1,6 MB per SE: 4.235 osservatori con stime,
peso e memoria ereditata). Al lancio successivo riprende e attraversa **solo le estrazioni nuove**:
da 4.237 passi a uno.

**Unico caso in cui il conto torna alto**: se si aggiunge una dimensione all'alfabeto, gli
osservatori salvati avrebbero imparato guardando altro — il file si rifiuta di essere ripreso e
serve ricamminare. È voluto: meglio ricamminare che ereditare una memoria sbagliata.

## File

| File | Ruolo |
|------|-------|
| `CaosEngine.cs` | L'alfabeto, gli osservatori, la verticalizzazione, il salvataggio dello sciame |
| `CaosVerifica.cs` | Il primo cammino con i controlli + la previsione incrementale |

```
Merlino.exe caos [n]   il primo cammino, n sciami indipendenti (una volta sola)
Merlino.exe            fra il resto, riprende lo sciame e dà la previsione verticale
```
