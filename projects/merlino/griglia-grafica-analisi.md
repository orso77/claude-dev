# Modello grafico su griglia — analisi

*17/08/2026. Ripartenza da zero: tutto il lavoro precedente è deprecato, metro di misura incluso.*

## La richiesta

Testuale, dall'utente:

> partendo dalla 1ª estrazione del 1997 voglio che crei un modello predittivo basato su una griglia
> grafica di 10 colonne per 9 righe. I numeri quando escono creano dei pattern grafici. Basandoti
> solo ed esclusivamente sui pattern grafici disegnati dalle estrazioni crea un modello predittivo
> per la prossima estrazione. Non c'è matematica, non c'è statistica, solo grafica.
>
> È quindi una sorta di algoritmo grafico che crea nuovi pattern grafici in base ai pattern grafici
> del passato.

E, sulla verifica:

> L'unico sistema di test del pattern grafico potrebbe essere vedere se, valutandolo sulle estrazioni
> storiche, riesci a predire il pattern delle prossime estrazioni. Partendo dall'inizio fino alla
> penultima estrazione deve identificare delle macchie calde per l'ultima estrazione (di cui hai i
> dati) in corrispondenza dei numeri realmente estratti. Solo questo metodo di verifica, nessun altro.

## Come è stato interpretato «solo grafica»

Il vincolo non è stilistico, è sostanziale: decide quali operazioni sono ammesse.

**Ammesso** — tutto ciò che si può fare con carta, matita e righello su una griglia: traslare una
figura, rifletterla, capovolgerla, sovrapporre due disegni, prolungare un tratto, allargare una
macchia sul bordo, ritagliare, confrontare due disegni guardando dove coincidono.

**Non ammesso** — tutto ciò che richiede di *contare qualcosa nel tempo*: quante volte è uscito un
numero (frequenza), da quanto manca (ritardo), quanto è caldo (densità recente), con che probabilità
esce (calibrazione), quali pesi rendono massimo un punteggio (taratura). Sono i mattoni di **tutti**
i modelli deprecati, e sono esattamente ciò che il vincolo esclude.

Conseguenza operativa: nel modello nuovo non esiste un solo array indicizzato per numero che
accumuli conteggi storici. Tutto è indicizzato per **cella della griglia**, e ciò che viaggia fra le
funzioni è un'**immagine** (`double[90]`, una griglia 10×9 di luminosità), mai un punteggio scalare
per numero.

## L'architettura

Sei canali, ognuno un'operazione di disegno che restituisce un'immagine della griglia.

Due canali **creano pattern nuovi a partire da pattern passati** — sono il cuore della richiesta:

- **Eco di forma.** La figura di adesso ha una *sagoma*: le sei celle traslate nell'angolo, senza
  più posizione. Si scorre tutto lo storico cercando figure con la stessa sagoma, nei quattro
  orientamenti che mandano la griglia in sé stessa (identità, specchio orizzontale, specchio
  verticale, mezzo giro). Dove la sagoma coincide, si prende la figura che venne **subito dopo**, le
  si applica lo stesso orientamento, e la si **ritrasla nella posizione di adesso**. Non si conta
  nulla: si ricalca un disegno e lo si rimette altrove.
- **Calco.** Le ultime cinque estrazioni sovrapposte con luminosità calante formano un *quadro*.
  Lo stesso quadro viene fatto scorrere su tutto lo storico; dove il disegno si somigliava di più, si
  ridisegna l'estrazione successiva.

Quattro canali **trasformano geometricamente la figura di adesso**:

- **Scia** — ogni cella si aggancia alla più vicina della figura precedente e continua lo stesso
  spostamento di un altro passo.
- **Specchio** — ogni cella accesa di recente accende i propri tre riflessi.
- **Crescita** — dilatazione: la figura si allarga di una cella sul bordo.
- **Retta** — due celle allineate tirano un tratto che prosegue oltre l'estremo.

### Dettagli implementativi che contano

- **Sagome come maschere di bit.** Ogni figura, in ciascuno dei 4 orientamenti, è precalcolata come
  coppia di `ulong` (90 celle > 64 bit). La somiglianza fra due sagome è un `AND` più due
  `PopCount`: l'Eco di forma confronta 4.237 × 4.237 × 4 sagome in tempo trascurabile.
- **Anti-leakage.** Per disegnare l'estrazione `t` si leggono solo le righe `[0, t)`. Le somiglianze
  storiche si fermano all'indice `t-2`, così il loro *seguito* è al massimo `t-1`. Non c'è modo che
  la riga bersaglio entri nel disegno.
- **Nessun parametro libero.** I sei lucidi si sommano a peso uguale. Non c'è random search, non c'è
  refinement, non c'è cache di pesi. È deliberato: la taratura è ciò che ha prodotto tutti i falsi
  positivi del progetto.

## Il ritaglio al mezzo tono — l'errore preso al volo

La **prima versione** sovrapponeva i sei lucidi così com'erano e normalizzava sul massimo. Il
risultato sull'estrazione di prova sembrava incoraggiante: i sei numeri usciti caddero su celle
`o : : O : .` — cioè quasi tutti dentro una macchia.

Guardando il disegno intero, però, **quasi metà griglia era tiepida o calda**: circa 18 celle su 90
da `O` in su, molte altre a `o`. Con macchie che coprono mezza schedina, cadere dentro una macchia è
il caso normale, non un successo. Il criterio non poteva fallire, quindi non verificava niente.

Il rimedio è a sua volta un'operazione di disegno: **ritagliare ogni lucido alla propria macchia**
prima di sovrapporlo (sotto il mezzo tono si cancella). Ogni canale contribuisce con la sua macchia,
non con la sua sfumatura di fondo. La soglia è il mezzo tono e basta — non è stata cercata, non è un
parametro tarato.

Effetto: da oltre 40 celle calde a **14 su 90**. E il verdetto si è capovolto.

Questo è lo stesso errore già commesso otto volte nel progetto (celebrare un +3-4% che era il
pavimento del rumore), qui in forma grafica anziché numerica. Vale la pena tenerlo a mente: **una
verifica che non può fallire non è una verifica**, e la versione "che funziona" era semplicemente
quella con la soglia più permissiva.

## Esito

Estrazione del **14/08/2026** — `09 18 20 25 53 90`. Modello costruito sulle prime 4.236 estrazioni
(dal 03/12/1997 al 13/08/2026), estrazione bersaglio mai vista.

| Numero uscito | Cella dove è caduto |
|---|---|
| 25 | tiepida (`o`) |
| 09 | appena tiepida (`:`) |
| 18 | spenta |
| 20 | spenta |
| 53 | spenta |
| 90 | spenta |

Disegno: 14 celle calde su 90. **Quattro numeri su sei nel vuoto**, nessuno su una macchia bollente.

Ripetendo la stessa verifica all'indietro sulle ultime 12 estrazioni (ognuna prevista da tutto ciò
che la precede), il quadro non cambia: la maggior parte dei numeri usciti cade su celle spente. I
pochi centri su macchia forte — `07#` e `29O` il 13/08, `21O` il 01/08, `16#` il 07/07 su EuroJackpot
— sono isolati e non si distinguono da coincidenze.

Su EuroJackpot (griglia 10×5, 869 estrazioni) l'esito è lo stesso: `05` tiepida, `26` appena tiepida,
`28` e `30` spente, `40` fredda, con 6 celle calde su 50.

**Conclusione: il modello grafico non mette le macchie dove escono i numeri.**

## Cosa dice questo esito

Il modello fa esattamente ciò che è stato chiesto: costruisce figure nuove a partire dalle figure del
passato, senza mai contare niente. Le figure che produce sono coerenti e localizzate — l'Eco di forma
ritrova davvero sagome ricorrenti, il Calco ritrova davvero quadri somiglianti. Ma il seguito di
quelle sagome, ridisegnato nella posizione di adesso, **non cade dove escono i numeri**.

La lettura più semplice è che la disposizione dei numeri sulla griglia 10×9 sia una convenzione
tipografica della schedina, non una proprietà dell'urna: le sei palline non sanno di essere disposte
in decine per riga. Qualsiasi struttura grafica trovata è struttura del *foglio*, non del sorteggio.
È coerente con tutto ciò che il progetto ha misurato finora per altre vie.

Nota metodologica: con una sola estrazione di verifica non si può distinguere «il modello non
funziona» da «questa volta è andata male». Ma il criterio richiesto era proprio questo, e ripetuto
all'indietro su 12 estrazioni dà lo stesso quadro. Se si volesse una risposta più netta servirebbe
tornare a contare — cioè al metro di misura che è stato esplicitamente deprecato.

---

# Il confronto di tutte le forme (17/08/2026)

Richiesta dell'utente: *«proviamo tutte le disposizioni della griglia possibili, comprese forme
diverse dal quadrato (ad esempio partiamo dal triangolo dove 1 sta all'apice) — scegli la forma
migliore per ottenere dei pattern predittivi efficienti»*.

La disposizione è l'unica leva davvero grafica del modello: gli stessi identici numeri, messi in
posizioni diverse, disegnano figure completamente diverse. Se una struttura grafica esiste, deve
vivere in **qualche** disposizione.

## Come è stato generalizzato il motore

`GrigliaLayout.cs`: la tela è un rettangolo `Righe × Colonne` ma **non tutte le celle portano un
numero**. Le altre restano vuote, non si accendono mai e vengono spente prima di ogni
normalizzazione (`Pulisci`). Così una forma qualsiasi vive dentro una tela rettangolare, e i canali
del modello restano identici.

Le maschere di sagoma sono passate da 2 a 4 parole da 64 bit: la tela può arrivare a 256 celle.

## Le disposizioni provate

**103 per il SuperEnalotto, 74 per l'EuroJackpot.** Famiglie:

| Famiglia | Varianti |
|---|---|
| Rettangoli | tutti i formati `righe × colonne` con `righe × colonne = 90` (1×90, 2×45, 3×30, 5×18, 6×15, 9×10, 10×9, 15×6, 18×5, 30×3, 45×2, 90×1), ciascuno riempito per righe, a serpentina, e per colonne |
| Triangoli | apice in alto, apice in basso, a serpentina |
| Piramidi centrate | apice in alto, apice in basso, a serpentina |
| Forme chiuse | rombo, esagoni di lato 4…9, cerchi pieni di lato 9…13, croci di braccio 1…4 |
| Curve | spirale dal centro, spirali rettangolari, diagonali, curva di **Hilbert** (16 e 32), curva **Z** di Morton |
| Trame | mattoni (righe sfalsate), scacchiere rade |
| **A caso** | **30 permutazioni completamente casuali dei 90 numeri sulla tela** |

Le 30 disposizioni **a caso** sono il pezzo decisivo. Scegliendo il massimo fra cento disposizioni
si trova sempre qualcosa che spicca, anche quando non c'è niente: una forma costruita vale solo se
batte le disposizioni casuali, non se batte 1,00.

## Il criterio

L'unico ammesso — macchie calde contro numeri realmente usciti — applicato a ogni disposizione e
ripetuto su un blocco di estrazioni:

- **COLPI** — quanti numeri usciti cadono dentro una macchia
- **MACCHIA** — quanta parte della tela il disegno tiene calda
- **GUADAGNO** — il rapporto fra i due

Contano solo insieme: una disposizione che tinge mezza tela prende molti colpi senza aver previsto
niente. **Guadagno 1,00 significa che le macchie prendono esattamente quello che prenderebbero per
la loro sola estensione**, cioè che il disegno non porta nessuna informazione.

Blocco di **scelta** 1.900 estrazioni, blocco di **conferma** le 1.900 più recenti, mai usate per
scegliere.

## La taratura dello strumento — il passaggio che mancava

Prima di credere a un esito negativo bisogna sapere se lo strumento saprebbe vedere un segnale
quando c'è. `GrigliaProva.cs` (`Merlino.exe prova`) costruisce storici **finti** dove ogni
estrazione è la precedente **spostata di una cella in diagonale**, tranne un certo numero di palline
rimpiazzate a caso, e ci passa la stessa identica misura.

| Palline a caso su 6 | Colpi | Macchia | **Guadagno** |
|---|---|---|---|
| 0 (segnale pieno) | 80,0% | 5,8% | **13,79** |
| 1 | 52,7% | 8,1% | **6,53** |
| 2 | 44,3% | 8,5% | **5,20** |
| 3 | 34,9% | 8,1% | **4,29** |
| 4 | 28,0% | 9,6% | **2,92** |
| 5 | 21,1% | 10,5% | **2,02** |
| 6 (nessun segnale) | 13,1% | 12,8% | **1,02** |

Lo strumento è **molto** sensibile: basta **una sola pallina su sei** che segua una regola grafica
perché il guadagno raddoppi. E su rumore puro segna 1,02, come deve.

Questo chiude la scappatoia: se sui dati veri il guadagno è 1,00, non è la misura a essere cieca.

## Esito

### SuperEnalotto — 103 disposizioni

| | Disposizione | Scelta | Conferma |
|---|---|---|---|
| Miglior forma costruita | Scacchiera larga | 1,037 | 0,996 |
| **Miglior disposizione a caso** | **A CASO #5 (15×6)** | **1,050** | **1,016** |

- Le 30 disposizioni **a caso**: da 0,934 a 1,050, **mediana 0,993**
- Le 73 forme **costruite**: da 0,955 a 1,037, **mediana 0,991**
- **Forme costruite sopra la migliore a caso: 0 su 73**
- La forma scelta, sul blocco di conferma, si piazza **42ª su 103**

### EuroJackpot — 74 disposizioni

| | Disposizione | Scelta | Conferma |
|---|---|---|---|
| Miglior forma costruita | Scacchiera rada | 1,063 | 0,947 |
| **Miglior disposizione a caso** | **A CASO #1 (5×10)** | **1,129** | **0,914** |

- A caso: mediana 1,018. Costruite: mediana 0,988. **0 su 44** sopra la migliore a caso.
- La forma scelta si piazza **63ª su 74** in conferma.

## Conclusione: la forma non conta

In entrambi i giochi la disposizione migliore è una **permutazione casuale**, nessuna delle forme
costruite la supera, e le mediane delle costruite e delle casuali coincidono. Tutte le 177
disposizioni provate stanno fra 0,90 e 1,13, cioè attorno a 1,00.

Triangolo, piramide, rombo, esagono, cerchio, croce, spirale, curva di Hilbert, scacchiera,
serpentina, tutti i formati di rettangolo, la schedina classica e una permutazione a caso: **tutte
uguali, tutte a zero informazione**.

Con lo strumento tarato a 2,02 per una sola pallina su sei che segua una regola grafica, il verdetto
è quantitativo: nelle estrazioni reali **non c'è nemmeno un sesto di pallina di segnale grafico**, in
nessuna delle 177 disposizioni.

L'interpretazione è la più semplice possibile: la posizione di un numero su una griglia è una
convenzione tipografica, non una proprietà dell'urna. Le sei palline non sanno dove il numero è
stampato sul foglio — e cambiando foglio, come si è visto, non cambia niente.

## Perché la giocata usa comunque la schedina 9×10

Siccome nessuna disposizione è migliore, la scelta si fa su un altro criterio: la **leggibilità**.
La griglia 9×10 è quella stampata sulla schedina, quindi i disegni che il programma stampa
corrispondono a quello che si ha sotto gli occhi giocando. Le costanti stanno in
`GrigliaLayout.SceltaSe / SceltaSs / SceltaEj / SceltaEuro`.

Scegliere invece la «Scacchiera larga» perché ha segnato 1,037 sarebbe stato esattamente l'errore
che questo confronto è servito a smascherare.

## Un bug che vale la pena ricordare

Il primo giro del confronto ha prodotto una classifica in cui **mancava tutta la famiglia dei
rettangoli riempiti per righe**, schedina 9×10 compresa: al loro posto compariva solo «Rett 1x90».

Causa: l'impronta usata per scartare i duplicati era la sola mappa `numero → indice piatto di cella`.
Ma quella mappa è **identica** per ogni rettangolo riempito per righe — 9×10, 6×15, 3×30 mandano
tutti il numero `n` sulla cella `n-1` — mentre la geometria, e quindi ogni figura disegnata, è
completamente diversa. Il deduplicatore le considerava la stessa disposizione e ne teneva una sola.

Effetto collaterale: anche `PerNome("Rett 9x10")` cadeva sul ripiego, e il percorso normale del
programma stava girando su una tela **1×90**, cioè una singola riga di 90 celle.

Corretto includendo la geometria nell'impronta (`Righe x Colonne` + mappa). Da lì il confronto è
salito da 92 a 103 disposizioni per il SuperEnalotto.

---

# Il banco di prova — scelta del sistema migliore (17/08/2026)

Richiesta dell'utente: *«fai tutti i test che ritieni opportuni e scegli il sistema migliore»*, con
la precisazione *«tanto lo puoi evincere simulando le estrazioni storiche»* — che è esattamente il
metodo: ogni configurazione **ricammina tutta la storia** e predice ogni estrazione usando solo ciò
che la precede.

`GrigliaConfig.cs` rende configurabili tutte le manopole di disegno (finestra, somiglianze, soglia
sagoma, taglio, tela a toro, quali canali accendere); `GrigliaTest.cs` (`Merlino.exe test`) le misura
tutte con l'unico criterio ammesso, su un blocco di **scelta** (1.900 estrazioni) e uno di
**conferma** (le 1.900 più recenti, mai usate per scegliere).

## Le cinque batterie

| | Cosa |
|---|---|
| **A** | I sei canali presi uno alla volta |
| **B** | Tutte le 63 combinazioni di canali |
| **C** | 17 varianti strutturali: tela a toro, sagome parziali/strette/identiche, finestra 2→15, somiglianze 4→200, taglio 0,30→0,85 |
| **D** | Le bande di controllo: stessa configurazione su numeri messi **a caso** sulla tela, e su storia con l'**ordine del tempo rimescolato** |
| **E** | Le ancore: la stessa ricerca su storici **finti** dove 1 o 2 palline seguono una regola grafica nota |

## A — i canali singoli (SuperEnalotto)

| Canale | Macchia | Scelta | Conferma |
|---|---|---|---|
| solo Specchio | 5,8% | 1,045 | 1,022 |
| solo Retta | 3,2% | 1,043 | 1,045 |
| solo Crescita | 5,5% | 1,000 | 0,945 |
| solo Scia | 3,4% | 0,990 | 0,998 |
| **tutti e sei (di partenza)** | 13,5% | 0,980 | 0,984 |
| solo Calco | 5,5% | 0,972 | 0,920 |
| solo Eco di forma | 5,6% | 0,949 | 1,047 |

## C — le varianti strutturali: nessuna aiuta

Le tre strade che erano rimaste aperte sono state provate e non portano niente:

| Variante | Scelta | Conferma |
|---|---|---|
| **Tela a toro** (i bordi si ricongiungono) | 0,975 | 0,973 |
| **Sagome parziali** (soglia 2 invece di 3) | 0,989 | 0,976 |
| toro + soglia 2 + finestra 9 | 0,973 | 0,988 |
| di partenza | 0,980 | 0,984 |

Tutte le 17 varianti stanno fra 0,973 e 1,029 in scelta. Finestra, somiglianze e taglio sono
altrettanto inerti.

## Una scoperta sull'architettura: il Calco non è un canale grafico

Nella batteria D è saltato fuori che la banda di controllo di «Calco» su 24 disposizioni casuali è
**1,096 .. 1,096** — identica su tutte. Non è un bug.

Il Calco confronta due quadri facendo il prodotto cella per cella e ne somma i valori. Quella somma
**non cambia se si rimescolano le etichette delle celle**: è invariante per permutazione della tela.
Il Calco quindi non usa affatto la geometria — lavora sugli insiemi di numeri, non sulle figure.

Conseguenze:
1. Spiega in parte perché il confronto delle 177 forme non riusciva a smuovere niente: uno dei sei
   canali ignora la forma per costruzione.
2. Per lui il controllo «disposizione a caso» è inerte, e serve l'altro — **rimescolare l'ordine
   temporale** delle estrazioni: gli stessi disegni, la stessa tela, ma senza più il filo del tempo.

Gli altri cinque canali (Eco di forma, Scia, Specchio, Crescita, Retta) usano davvero la geometria e
la loro banda di controllo varia regolarmente.

## Il verdetto

### SuperEnalotto — 1.900 + 1.900 estrazioni

| | Valore |
|---|---|
| Miglior configurazione sui dati veri | **Specchio 1,045** |
| la stessa sul blocco di conferma | 1,022 — **11ª su 63** |
| la stessa su numeri messi **a caso** sulla tela | **0,914 .. 1,048** |
| la stessa con l'ordine del tempo **rimescolato** | **0,920 .. 1,069** |
| **Ancora**: 1 pallina su 6 con regola grafica | **4,651** → conferma **6,313**, **1ª su 63** |

### EuroJackpot — 309 + 309 estrazioni

| | Valore |
|---|---|
| Miglior configurazione sui dati veri | **Calco 1,096** |
| la stessa sul blocco di conferma | 1,022 — 7ª su 63 |
| la stessa con l'ordine del tempo **rimescolato** | **0,864 .. 1,112** |
| **Ancora**: 1 pallina su 5 con regola grafica | **3,078** → conferma **3,540**, **1ª su 63** |

**In entrambi i giochi la configurazione migliore cade dentro le proprie bande di controllo.** Lo
stesso identico modello, girato su numeri messi a caso sulla tela o su una storia con il tempo
mescolato, arriva altrettanto in alto. Non c'è nulla che il modello stia leggendo nei dati veri e non
legga nel disordine.

Le ancore chiudono il discorso dall'altro lato: bastava che **una pallina su sei** seguisse una
regola grafica perché la ricerca la trovasse a 4,65, la confermasse a 6,31 e la piazzasse **prima su
63** anche nel blocco mai usato per sceglierla. Il banco di prova vede benissimo. Nei dati veri non
c'è niente da vedere.

## Il sistema scelto

**Tutti e sei i canali, parametri di partenza, schedina 9×10.** Le ragioni sono queste, in ordine:

1. **Nessuna configurazione batte misurabilmente le altre.** La scelta non si può fare sulla
   prestazione, perché non c'è prestazione da confrontare.
2. **Scegliere «solo Specchio» perché ha segnato 1,045 sarebbe l'errore che il banco serve a
   evitare**: la sua banda di controllo arriva a 1,048 mettendo i numeri a caso e a 1,069
   rimescolando il tempo. Il vincitore è battuto dal proprio controllo.
3. **A parità di tutto, si tiene la configurazione più ricca e leggibile**: sei lucidi disegnano un
   quadro più informativo da guardare di un canale solo, e la 9×10 è la schedina che si ha in mano.

Detto in una riga: il sistema migliore è quello che non pretende di essere migliore.

---

# Quattro costrutti grafici nuovi (17/08/2026)

Richiesta dell'utente: *«crea tu un pattern grafico, un algoritmo grafico che riesca a predire i
pattern grafici futuri in base a quelli passati. In fondo si tratta di vedere le estrazioni come
disegni e predire quale sarà il prossimo disegno in base ai disegni del passato»*.

Non più misurare quello che c'è: inventarne di nuovi. Quattro costrutti, portati da 6 a 10 canali.

## Analogia — «A sta a B come C sta a X»

L'**Eco di forma**, trovata una figura A somigliante a quella di adesso, ridisegna il seguito B così
com'era. L'**Analogia** fa un'altra cosa: guarda **come** A si è trasformata in B — di quanto e in
che verso si è mosso ognuno dei suoi punti — e applica **quello stesso cambiamento** alla figura di
adesso. Non copia il risultato di allora: copia il gesto che lo produsse.

La differenza si vede quando A somiglia a C solo in parte: l'Eco disegna comunque B intera,
l'Analogia disegna C deformata come lo fu A. È il classico ragionamento per analogia, applicato a
figure.

## Gesto — il disegno come scrittura a mano

La penna entra dalla cella più in alto a sinistra e passa ogni volta alla più vicina non ancora
toccata: ne esce un **tracciato**, e la sequenza dei tratti è la *grafia* di quel disegno.

Si cercano nello storico le figure scritte con la **stessa grafia** — non nella stessa posizione,
proprio con gli stessi tratti — e si continua a scrivere: il gesto che allora venne dopo, ripreso dal
punto in cui la penna si è fermata adesso.

È l'unico canale che tratta il disegno come **sequenza** invece che come insieme.

## Piega — il foglio come lenzuolo elastico

Fra le ultime due estrazioni ogni cella si è spostata. Quei pochi spostamenti sono i **campioni di
una piega che interessa tutto il foglio**: nei punti in mezzo la piega si indovina per vicinanza
(interpolazione inversa alla distanza). Ottenuta la piega, la si applica una seconda volta — non alle
sei celle, ma all'**intero quadro** delle ultime estrazioni, che scivola sul foglio nel verso in cui
già stava scivolando.

Differenza dalla Scia: la Scia muove sei punti, la Piega deforma tutta l'immagine.

## Contorno — il disegno come area, non come punti

Sei celle sparse individuano una macchia: il loro **guscio convesso riempito**. Due estrazioni
possono avere **zero celle in comune** e nondimeno occupare la stessa area con la stessa forma.

Si confrontano i gusci — quanta area si sovrappone portandoli uno sopra l'altro — e si ridisegna il
guscio che allora venne dopo, nella posizione di adesso.

## I nuovi canali sono migliori dei vecchi — sul segnale vero

La taratura su storici finti, rifatta con dieci canali, migliora su tutta la scala:

| Palline a caso su 6 | 0 | 1 | 2 | 3 | 4 | 5 | 6 |
|---|---|---|---|---|---|---|---|
| **6 canali** | 13,79 | 6,53 | 5,20 | 4,29 | 2,92 | 2,02 | 1,02 |
| **10 canali** | **14,44** | **7,35** | **5,54** | **4,58** | **3,30** | **2,07** | 1,03 |

E nella batteria delle ancore, l'**Analogia da sola** si piazza terza su 1023 combinazioni nel
riconoscere un segnale grafico di una pallina su sei (4,045), subito dietro l'Eco di forma. Il
costrutto funziona: sa vedere una regola grafica quando c'è.

## Esito sui dati veri

### SuperEnalotto — i dieci canali singoli, 1.900 + 1.900 estrazioni

| Canale | Macchia | Scelta | Conferma |
|---|---|---|---|
| **Gesto** | 2,1% | **1,081** | 1,022 |
| Specchio | 5,8% | 1,045 | 1,022 |
| Retta | 3,2% | 1,043 | 1,045 |
| *tutti e dieci* | 12,6% | 1,017 | 0,995 |
| **Analogia** | 4,0% | 1,016 | 1,018 |
| **Contorno** | 18,5% | 1,015 | 1,001 |
| Crescita | 5,5% | 1,000 | 0,945 |
| Scia | 3,4% | 0,990 | 0,998 |
| **Piega** | 3,6% | 0,980 | 1,010 |
| Calco | 5,5% | 0,972 | 0,920 |
| Eco di forma | 5,6% | 0,949 | 1,047 |

Il **Gesto** è il miglior canale singolo mai ottenuto nel progetto: 1,081. Ma:

| | Valore |
|---|---|
| Gesto sul blocco di conferma | 1,022 — **164ª su 1023** |
| Gesto su numeri messi **a caso** sulla tela | 0,798 .. **1,112** |
| Gesto con l'ordine del tempo **rimescolato** | 0,874 .. **1,113** |
| **Ancora**: 1 pallina su 6 con regola grafica | **4,651**, **1ª su 1023** anche in conferma |

**1,081 sta dentro entrambe le bande di controllo.** Lo stesso Gesto, girato su numeri messi a caso
sulla tela o su una storia col tempo mescolato, arriva a 1,11 — più in alto di quanto faccia sui dati
veri. L'EuroJackpot dice lo stesso (Calco 1,096, tetto dei controlli 1,112).

Nemmeno le varianti strutturali si muovono: fra 0,996 e 1,025 tutte e dodici.

## La conclusione che conta

Il punto non è che i costrutti nuovi siano deboli. **Sono i migliori mai costruiti nel progetto**, e
lo si può dimostrare: alzano la sensibilità dello strumento su tutta la scala del segnale finto, e
l'Analogia da sola riconosce una regola grafica su una pallina su sei con un guadagno di 4,0.

Il punto è che quando gli stessi identici costrutti guardano le estrazioni vere, segnano 1,00 —
esattamente come segnano su numeri messi a caso sulla tela e su una storia col tempo mescolato.

**Non è il disegnatore a essere cieco. È il foglio a essere bianco.**

## Nota di ingegneria: la cache dei lucidi

Con dieci canali le combinazioni diventano 1023, e ricalcolare i lucidi per ognuna faceva durare il
banco **oltre dieci minuti**. I dieci lucidi di ogni estrazione ora si calcolano **una volta sola**
(`GrigliaEngine.LucidiRitagliati`) e poi si combinano (`Componi`): stesso risultato, **10 secondi**.
Il caso da manuale in cui la struttura del calcolo, non il calcolo, è il collo di bottiglia.

---

# Il modello guardava il centro della tela — difetto reale e correzione (17/08/2026)

Segnalazione dell'utente su una giocata proposta (`18 19 20 22 27 29`): *«tutti e 6 i numeri sono
sotto a 30, mi sembra molto improbabile»*.

È la **seconda volta** che un'intuizione di questo tipo scova un difetto vero (la prima fu
l'inclinazione verso i numeri alti di Bilancia, agosto 2026). La direzione indovinata era sbagliata,
il difetto sotto c'era eccome — ed era peggiore.

## La diagnostica

`GrigliaScelte.cs` (`Merlino.exe scelte`) non misura se il modello indovina: misura **dove guarda**.
Ricamminando 2.000 estrazioni annota quali celle il modello sceglie e confronta la distribuzione con
quella delle estrazioni vere.

| riga | scelti dal modello | usciti davvero | neutro |
|---|---|---|---|
| 1-10 | **3,8%** | 11,0% | 11,1% |
| 11-20 | 6,2% | 10,8% | 11,1% |
| 21-30 | 10,9% | 10,6% | 11,1% |
| 31-40 | 15,0% | 11,0% | 11,1% |
| **41-50** | **20,8%** | 11,1% | 11,1% |
| 51-60 | 15,9% | 11,1% | 11,1% |
| 61-70 | 12,5% | 11,2% | 11,1% |
| 71-80 | 8,5% | 11,4% | 11,1% |
| 81-90 | **6,4%** | 11,8% | 11,1% |

Il **46** veniva scelto nel **22,5%** delle estrazioni, il **10** nell'**1,4%**: sedici volte tanto,
fra numeri che escono con la stessa frequenza. Il 45 e il 46 sono esattamente le celle centrali della
griglia 9×10. Le estrazioni vere sono piatte.

Il modello non preferiva i numeri bassi: **preferiva il centro del foglio**, e quella giocata era
solo il caso particolare di un difetto generale.

## Prima causa: la perdita dei bordi

Crescita, Retta, Scia, Eco, Analogia, Gesto e Contorno traslano e prolungano figure, e **tutto ciò
che finisce oltre il margine veniva buttato via**. Una cella centrale riceve tratti da ogni
direzione, una cella d'angolo solo da dentro. Non era una preferenza del modello: era una perdita.

Correzione: **tela a toro accesa di default** (`GrigliaConfig.Toro = true`). I bordi si ricongiungono,
nessun tratto si perde, ogni cella vale quanto le altre. Era già implementata e misurata nel banco —
dove risultava indifferente sulla resa (1,012 contro 1,017) — ma il suo valore vero non è la resa: è
l'equità geometrica.

Esito: riga 1-10 da 3,8% a 8,0%. Migliorata, non risolta.

## Seconda causa: il Contorno, e non è raddrizzabile

L'inclinazione misurata canale per canale (quota delle scelte nella fascia centrale, neutro 33,3%):

| Canale | Fascia centrale |
|---|---|
| **Contorno** | **84,7%** |
| **Analogia** | 45,4% |
| Specchio | 39,3% |
| Eco di forma | 33,2% |
| Calco | 32,8% |
| Crescita | 30,4% |
| Gesto | 28,4% |
| Scia | 25,4% |
| Piega | 25,1% |
| Retta | 20,6% |

Il **Contorno** — costrutto inventato poche ore prima — è il guastafeste. La causa è geometrica e
non ha niente a che vedere con le estrazioni: il **guscio convesso di sei punti sparsi sta addosso al
centro della tela molto più che ai margini**, perché il centro sta "in mezzo" a più coppie di punti
di quanto ci stia un angolo. Il toro non lo corregge, perché il guscio si calcola nel piano.

Primo tentativo: usare il **bordo** del guscio invece dell'area piena — che è anche ciò che la parola
*contorno* vuol dire. Il vizio si dimezza (84,7% → 51,9%) ma resta; sulla griglia EuroJackpot a 5
righe è ancora al 97,6% contro un neutro del 60%. Il difetto è nella natura del guscio, non nel suo
riempimento.

## La scelta: equità, visto che sulla resa sono tutte uguali

Nessuna combinazione esce dalle bande di controllo, quindi il criterio di scelta non può essere la
resa. Diventa lo **squilibrio**: riga più servita diviso riga meno servita.

| Combinazione | riga min | riga max | squilibrio |
|---|---|---|---|
| **senza Contorno** | 10,2% | 13,8% | **1,35x** |
| senza Contorno, Analogia, Specchio | 9,9% | 13,4% | 1,35x |
| senza Contorno e Analogia | 9,7% | 13,4% | 1,39x |
| i sei originali | 9,6% | 13,6% | 1,42x |
| tutti e dieci | 6,8% | 16,8% | 2,49x |
| solo i quattro nuovi | 3,2% | 17,0% | **5,35x** |
| *estrazioni vere* | | | *1,11x* |

Togliere l'Analogia peggiora leggermente le cose, quindi resta. Il colpevole è uno solo.

## Il sistema finale

**Nove canali — tutti tranne il Contorno — tela a toro, schedina 9×10.**

Distribuzione risultante, contro 11,1% neutro:

| riga | 1-10 | 11-20 | 21-30 | 31-40 | 41-50 | 51-60 | 61-70 | 71-80 | 81-90 |
|---|---|---|---|---|---|---|---|---|---|
| modello | 11,6% | 10,5% | 10,5% | 10,6% | 13,8% | 10,7% | 10,9% | 10,2% | 11,2% |
| estrazioni vere | 11,0% | 10,8% | 10,6% | 11,0% | 11,1% | 11,1% | 11,2% | 11,4% | 11,8% |

Piatta. La giocata è passata da `18 19 20 22 27 29` a `01 09 18 19 20 90`.

## La lezione

Un modello può essere **inutile e storto insieme**, e le due cose si misurano separatamente. Tutto il
banco di prova diceva 1,00 — cioè "non predice niente" — e quel giudizio era corretto; ma non diceva
nulla sul fatto che le scelte fossero distribuite in modo assurdo. Un criterio che normalizza per
l'estensione della macchia è cieco a *dove* la macchia sta.

Serviva una diagnostica diversa, ed è nata solo perché qualcuno ha guardato l'output e ha detto
«questo mi sembra strano». Vale la pena tenerlo a mente: **l'occhio su un singolo risultato ha
trovato due difetti che migliaia di misure automatiche non avevano visto.**

---

# L'Occhio — il ragionamento dell'utente dentro l'algoritmo (17/08/2026)

Richiesta: *«sviluppa tu un occhio come il mio basandoti sulle mie osservazioni, ragiona come me»* e
*«implementa il ragionamento nell'algoritmo dell'app»*.

## Il ragionamento, smontato

Il ragionamento dell'utente ha due tempi, e **solo il secondo è quello che vale**:

1. si nota qualcosa che salta all'occhio — *«tutti e sei sotto il 30…»*
2. si conclude *«mi sembra improbabile»*

Il passo 2, da solo, **sbaglia quasi sempre**: la sensazione di impossibilità segue la
*descrivibilità*, non la probabilità. «Tutti fra 60 e 90» sembra assurdo ed è uscito 5 volte in
4.234 estrazioni, esattamente le 5,01 attese.

Ma qui non si guarda un'estrazione: si guarda **l'output di un modello**. E allora la domanda
giusta non è *«quanto è raro?»* ma:

> **Il modello lo fa più spesso di quanto capiti davvero?**

Questa è la domanda che ha trovato due difetti veri. È formalizzabile, e `GrigliaOcchio.cs` la
formalizza: per ogni tratto notabile riporta tre numeri — se la giocata di adesso ce l'ha, quanto
capita nelle estrazioni vere, quanto il modello lo produce ricamminando la storia.

## I dieci tratti che l'occhio guarda

Tutti e sei nello stesso terzo · almeno cinque nella stessa metà · ampiezza stretta · tre sulla
stessa riga · tre sulla stessa colonna · una coppia di consecutivi · tre consecutivi di fila · tre
celle che si toccano sulla griglia · tre allineate · tutti pari o tutti dispari.

## Cosa ha trovato subito

| tratto | vere | modello | scarto |
|---|---|---|---|
| tutti nello stesso terzo | 0,2% | 1,5% | **6,4x** |
| ampiezza stretta | 1,5% | 7,7% | **5,0x** |
| tre o più consecutivi | 1,3% | 5,2% | **3,9x** |
| tre celle che si toccano | 16,2% | 43,4% | **2,7x** |

**Il modello disegna macchie, e prendere le sei celle più luminose significa prendere sei punti dello
stesso fianco della stessa collina.** Le estrazioni vere sono sei punti sparsi. L'osservazione
originale dell'utente («tutti sotto il 30») era il caso particolare di questo.

## La correzione: le vette, non le cime

Operazione grafica classica, la **soppressione dei non-massimi**: si prende la vetta, poi si abbassa
il fianco della collina, poi si prende la vetta successiva. Si raccolgono le *vette*, una per collina
— come si contano le stelle su una lastra.

### Prima sovracorrezione, presa dall'occhio stesso

Vietare del tutto le celle confinanti ha portato *«almeno una coppia di consecutivi»* da 33,8% (vero)
a **0,0%** nel modello. Ma un'estrazione su tre ha numeri consecutivi: renderli impossibili è
l'errore opposto, altrettanto grave.

La correzione giusta è **attenuare**, non vietare: le confinanti perdono luce, quelle a due passi la
perdono a metà, ma se una cella accanto resta comunque la più chiara viene presa lo stesso.

### Quanto attenuare — taratura di forma, non di resa

`Merlino.exe vette` prova tutta la scala e misura lo scostamento medio fra la forma delle giocate del
modello e quella delle estrazioni vere:

| attenuazione | 0,00 | 0,35 | 0,50 | 0,65 | **0,80** | **0,90** | 1,00 |
|---|---|---|---|---|---|---|---|
| SuperEnalotto | 2,426 | 1,988 | 1,700 | 1,151 | **0,241** | 0,293 | 0,808 |
| EuroJackpot | 3,023 | 2,327 | 1,412 | 0,743 | 0,326 | **0,157** | 0,415 |

Curva a U con minimo netto in entrambi i giochi. Scelto **0,85**, un solo valore per entrambi — non
uno per gioco, che sarebbe stato adattamento.

**Nota importante**: questa *non* è taratura di resa, che il progetto ha imparato a caro prezzo a non
fare. È taratura di **forma**: un modello di estrazioni deve produrre cose che somigliano a
estrazioni. L'obiettivo è misurabile, non ha nulla a che vedere con l'indovinare, e non può gonfiare
nessuna metrica di prestazione.

## Esito

| tratto | vere | modello | scarto |
|---|---|---|---|
| tutti nello stesso terzo | 0,2% | 0,3% | 1,4x |
| almeno tre sulla stessa colonna | 12,3% | 15,5% | 1,3x |
| almeno tre sulla stessa riga | 14,8% | 17,4% | 1,2x |
| ampiezza stretta | 1,5% | 1,7% | 1,1x |
| tre allineate | 46,1% | 49,7% | 1,1x |
| tutti pari o tutti dispari | 2,9% | 2,9% | 1,0x |
| tre o più consecutivi | 1,3% | 1,3% | 1,0x |

Da scarti fino a 6,4x a **tutto fra 0,5x e 1,8x**, quasi tutto fra 0,8 e 1,3.

## Il campo piatto — la vignettatura dell'obiettivo

Correzione entrata nell'algoritmo insieme all'occhio. Un obiettivo fotografico illumina il centro del
fotogramma più dei bordi, e non si corregge a occhio: si fotografa una superficie uniforme, si misura
quanta luce arriva a ogni punto, e si divide ogni scatto per quella misura.

`GrigliaEngine.TaraCampo` fa esattamente questo: misura quanta luce ogni cella riceve **in media** su
un pezzo di storia, e da lì in avanti divide ogni disegno per quella misura. Una cella non è più
calda in assoluto — è calda **rispetto a quanto è solita essere**.

Tarato su estrazioni tutte precedenti a quelle previste (nessuna fuga). Esito sul SuperEnalotto: la
riga centrale scende da 13,8% a 10,8%, contro l'11,1% neutro.

**Trappola trovata**: con pochi campioni il campo *è* rumore, e dividere per rumore aggiunge storture
invece di toglierne — su EuroJackpot con 35 campioni lo squilibrio peggiorava da 1,21x a 1,99x. Ora
sotto i 200 campioni la correzione non si applica affatto.

## Distribuzione finale

| riga | 1-10 | 11-20 | 21-30 | 31-40 | 41-50 | 51-60 | 61-70 | 71-80 | 81-90 |
|---|---|---|---|---|---|---|---|---|---|
| modello | 10,7% | 11,1% | 12,6% | 12,0% | 10,8% | 12,0% | 10,6% | 10,7% | 9,4% |
| estrazioni vere | 11,0% | 10,8% | 10,6% | 11,0% | 11,1% | 11,1% | 11,2% | 11,4% | 11,8% |

Squilibrio 1,33x sul SuperEnalotto e 1,17x sull'EuroJackpot, contro l'1,11x delle estrazioni vere.

## Cosa questo NON cambia

Va detto senza ambiguità: **niente di tutto questo migliora la resa**. Il modello continua a segnare
1,00 sul banco di prova, continua a non predire niente, e la probabilità di vincere non è cambiata di
un capello — sei numeri qualsiasi valgono sei numeri qualsiasi.

Quello che è cambiato è che il modello non è più **storto**: non pesca più il 46 sedici volte più del
10, e non propone più giocate ammassate che nessuna estrazione vera somiglia. Un modello inutile ma
onesto è meglio di un modello inutile e storto — se non altro perché il secondo fa credere di vedere
qualcosa.

## L'occhio gira a ogni avvio

`GrigliaOcchio.Guarda` è chiamato in coda al percorso normale: commenta la giocata appena prodotta,
segnala i tratti che saltano all'occhio e — soprattutto — quelli su cui il modello sta esagerando
anche se non compaiono in questa giocata. È la sentinella permanente contro il prossimo difetto di
questo tipo.

## File

| File | Ruolo |
|------|-------|
| `GrigliaEngine.cs` | Griglia, sei canali, ritaglio, sovrapposizione, disegno a schermo |
| `GrigliaVerifica.cs` | L'unica verifica: macchie calde contro numeri realmente usciti |
| `Program.cs` | Scaricamento (invariato) → figure → verifica → giocata |

35 file di algoritmi precedenti portano in testa il banner `// DEPRECATO`: restano sul disco e
compilano, ma nessuno è chiamato dall'applicazione.
