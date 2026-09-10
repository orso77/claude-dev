# La misura di `cerca` non è la misura che serve — l'undicesima tornata e il muro (10/09/2026)

> Mandato dell'utente: *«fai tutto ciò che serve per avere una predizione il più efficace
> possibile»*. Questo file è il risultato più utile della giornata, e non è una scoperta: è un
> **errore preso in tempo**, e il modo in cui è stato preso.

## Cosa dice `cerca`, e cosa NON dice

`cerca` misura, per ogni sguardo, **quanto separa le estrazioni vere dalle combinazioni qualunque**,
al netto del proprio fondo di rumore. È il criterio adottato il 24/08 e ha fatto trovare tutte le
dimensioni buone del progetto.

Ma misura una dimensione **da sola**. Non misura **quanto aggiunge a quelle già presenti**. Sono due
domande diverse, e fino a oggi erano state confuse — senza conseguenze visibili, perché le tornate
precedenti cercavano in direzioni distanti fra loro.

## Come si è visto il problema

La decima tornata aveva fatto passare tre sguardi (il seguito, il posto del più atteso, il ritmo
proprio), e il **braccio appaiato** costruito lo stesso giorno diceva che valevano
**+0,0305 ± 0,0151 = +2,02 σ** sul SuperEnalotto. Poco, ma vero.

L'undicesima è andata a cercare **nell'intorno di quei tre**, che è il metodo della quinta tornata e
aveva funzionato. Ha trovato sette sguardi con netti dentro la fascia buona:

| sguardo | netto SE | netto EJ |
|---|---|---|
| quanti fra i più seguiti dell'ultima, **in proporzione** | +0,0174 | +0,0214 |
| quanti dei primi tre posti sono sopra il proprio passo | +0,0141 | −0,0059 |
| quanti sono **seguiti E** oltre metà del proprio passo | +0,0105 | +0,0148 |
| quanti fra i **sei** più seguiti dell'ultima | +0,0032 | +0,0333 |
| in che posto della sestina sta il passo più lungo | −0,0052 | +0,0186 |
| quanti fra i più seguiti delle **ultime due** | −0,0064 | +0,0167 |
| quanti sono seguiti **E freschi** | +0,0007 | +0,0150 |

Tutti positivi dove sono stati adottati. Adottati. E la catena è **peggiorata**:

| | prima | dopo | braccio appaiato |
|---|---|---|---|
| **SuperEnalotto** | 1,1944 | **1,1625** | **−0,0319 ± 0,0153 = −2,08 σ** |
| **EuroJackpot** | 1,3432 | **1,3215** | −0,0217 ± 0,0267 = −0,81 σ |

**Due sigma di peggioramento, provati.** Non un sospetto: la stessa misura appaiata che due ore prima
aveva certificato il guadagno della decima tornata, applicata all'undicesima, dà il segno opposto.

## Perché: la ridondanza pesa

La catena giudica una candidata sommando, su **tutte** le dimensioni, quanto il suo valore è raro nel
catalogo, ciascuna pesata per la propria presenza. La somma presuppone che le dimensioni dicano cose
**diverse**. Cercare nell'intorno di un vincitore produce, per costruzione, dimensioni che dicono la
**stessa** cosa:

- «i 18 più seguiti», «i 18 più seguiti in proporzione», «i 6 più seguiti», «i più seguiti delle
  ultime due» sono **quattro modi di scrivere la stessa classifica**;
- «seguiti **E** oltre metà del passo» e «seguiti **E** freschi» sono **congiunzioni** di due
  dimensioni già presenti: non aggiungono un asse, ne raddoppiano due.

Il risultato è che quell'unico indizio finisce per pesare quanto quattro, e schiaccia i 140 assi
indipendenti che c'erano. Ogni singola variante «separa bene» e insieme fanno danno.

## La controprova: non è (solo) la ridondanza — è la saturazione

L'ipotesi «erano troppe varianti dello stesso indizio» andava provata, non creduta. Prova: **togliere
tutto e lasciarne UNA sola**, la migliore mai misurata in una tornata.

Sull'EuroJackpot è stata tenuta solo «quanti fra i **sei** più seguiti dell'ultima», netto **+0,0333**
— il valore più alto uscito da qualunque tornata su quel tabellone.

| EuroJackpot | dimensioni | centri medi |
|---|---|---|
| decima tornata | 160 | **1,3432** |
| + le sei dell'undicesima | 166 | 1,3215 |
| **+ una sola, la migliore** | 161 | **1,3364** |

Anche **una sola** non aggiunge: il braccio appaiato la dà a **−0,0069 ± 0,0265 = −0,26 σ**, cioè
zero. Togliere le altre cinque recupera quasi tutto il danno, quindi la ridondanza *pesa* — ma non
spiega perché il guadagno atteso non arrivi mai.

La lettura più onesta è più severa:

> **A 160 dimensioni la tavola è satura.** Uno sguardo che separa bene *da solo* non porta quasi mai
> informazione *nuova*: lo spazio delle domande formulabili sulla singola sestina è già coperto da
> ciò che c'è. Il netto di `cerca` continua a salire, la resa della catena no.

Converge con il bersaglio spostato del 18/08 — «lo spazio informativo del SuperEnalotto (25.422
interi ordinati crescenti) è chiuso: ogni occhio nuovo ne è una riparametrizzazione». Allora era
stato detto dei modelli; adesso lo si vede sulle **dimensioni**, con lo strumento che misura il
contributo marginale invece di quello isolato.

## Il terzo tentativo: sostituire invece di aggiungere. Anche quello no.

Restava una via: se il problema è che le varianti si sommano, allora la variante migliore deve
**prendere il posto** di quella vecchia, lasciando il conto delle dimensioni invariato.

Sul SuperEnalotto «quanti sono fra i più seguiti dell'ultima» è passato dalla classifica **grezza** a
quella **pesata**, che `cerca` misura meglio (0,0174 contro 0,0161). Tavola sempre a 142.

| SuperEnalotto | dimensioni | centri medi |
|---|---|---|
| seguito **grezzo** (decima tornata) | 142 | **1,1944** |
| seguito **pesato** (undicesima) | 142 | 1,1785 |

**Lo sguardo che `cerca` misura meglio rende di meno nella catena.** È il caso più pulito della
giornata, perché elimina ogni altra spiegazione: stesse dimensioni, stesso numero, stesso tutto —
cambia solo *quale* classifica del seguito si guarda, e quella che separa meglio da sola porta meno
alla squadra.

Con questo i tentativi di alzare la resa sono tre su tre falliti: **aggiungere sette**, **aggiungere
una sola**, **sostituirne una**. La configurazione migliore resta quella della decima tornata.

## Un sospetto che vale più della tornata: il bersaglio è sbagliato

Guardando gli istogrammi delle quattro configurazioni provate si vede una cosa che il numero dei
centri medi nasconde. **Il SuperEnalotto non paga nulla con uno o due numeri**: il premio comincia a
tre.

| configurazione | centri medi | **volte con 3 o più centri** |
|---|---|---|
| 139 dimensioni (prima di oggi) | 1,1640 | **53** |
| 142, decima tornata | **1,1944** | 47 |
| 142, seguito pesato | 1,1785 | 47 |
| 145, undicesima | 1,1625 | 40 |

La configurazione che vince sui centri medi **non è quella che ha fatto più «punti 3»**. Va detto
subito che con una cinquantina di eventi su 2.824 la fluttuazione tipica è ±7, quindi **53 contro 47
non è distinguibile**: non si sta dicendo che la tavola vecchia fosse migliore. Si sta dicendo che
**sulla metrica che paga non c'è ancora nessuna informazione**, perché l'evento è troppo raro.

Ma il punto resta: passare da un centro a due non vale una lira, ed è lì che la catena mette quasi
tutto il proprio guadagno (2 centri: da 587 a 664). Due strade misurabili, mai provate:

1. **cambiare bersaglio** — scegliere le cinque sestine per massimizzare la probabilità che *almeno
   una* faccia 3+, invece della media dei centri. È un criterio dentro `Blocco.Scegli`.
2. **cambiare il modo di combinare** — la somma di implausibilità pesata per presenza è una scelta
   del 20/08, mai messa alla prova contro un'alternativa. Ora il braccio appaiato può misurarla.

## La regola che ne esce, da applicare d'ora in poi

1. **Il netto di `cerca` è un filtro di ammissione, non un criterio di adozione.** Nessuna dimensione
   entra nella tavola finché il **braccio appaiato** non ha detto che aggiunge qualcosa.
2. **Prima di adottare una variante di uno sguardo già in tavola, si sostituisce, non si aggiunge.**
   Se la nuova misura meglio, prende il posto della vecchia.
3. **Le congiunzioni di due dimensioni presenti vanno trattate come ridondanti fino a prova
   contraria**, non come un asse nuovo.
4. **La ricerca va portata LONTANO da ciò che c'è già**, non vicino. Il metodo «l'intorno dei
   vincitori» della quinta tornata funzionava quando la tavola era piccola e gli assi erano pochi:
   con 142 dimensioni l'intorno è già coperto.
5. **E probabilmente non basta nemmeno andare lontano**, finché si resta dentro «altre domande sulla
   stessa sestina»: la controprova dice che la tavola è satura. Il margine, se c'è, va cercato
   altrove — non in una dimensione in più, ma in un modo diverso di **combinarle** (la somma di
   implausibilità pesata per presenza è una scelta, non una legge), oppure in dati che oggi non
   entrano affatto nel giudizio.

## Cosa sarebbe successo senza il braccio appaiato

Sarebbe stata consegnata una catena **peggiore**, dichiarata migliorata, con a corredo una tabella di
sette netti tutti positivi a sostegno. È esattamente la forma di errore contro cui il progetto si è
attrezzato dal 24/08 — «un criterio che non può fallire non è una verifica» — ripresentata in una
veste nuova: qui il criterio *poteva* fallire, ma era il criterio **sbagliato**.

Il braccio appaiato era stato costruito la mattina stessa per provare la decima tornata. Ha ripagato
il proprio costo nel giro di poche ore, bocciando la tornata successiva.
