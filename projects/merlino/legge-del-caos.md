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

## Tempi — vincolo dell'utente: max 60 secondi per avvio

Rispettato e **cronometrato**, non promesso:

| | primo cammino (una volta) | avvio incrementale |
|---|---|---|
| SuperEnalotto | 25,8 minuti | **2,6 secondi** |
| EuroJackpot | incluso | **0,1 secondi** |

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
