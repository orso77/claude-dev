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

## Strade grafiche ancora non provate

Restano aperte, tutte disegno puro:

- **Toro anziché rettangolo.** Ora le figure che escono dal bordo vengono tagliate. Ricongiungendo i
  lati (destra con sinistra, alto con basso) nessuna figura si perde e le traslazioni diventano
  complete. È l'unica modifica strutturale ai canali, non alla disposizione.
- **Sagome parziali.** L'Eco di forma cerca la sagoma di tutte e sei le celle. Cercare le sagome di
  sottoinsiemi di tre o quattro darebbe molte più corrispondenze, ognuna più debole.
- **Contorno anziché celle.** Trattare la figura come poligono — perimetro, area, angoli — invece che
  come insieme di punti.

Va detto con chiarezza: dopo 177 disposizioni tutte a 1,00, con uno strumento che vede mezzo segnale
su sei palline, l'attesa ragionevole per queste strade è la stessa.

## File

| File | Ruolo |
|------|-------|
| `GrigliaEngine.cs` | Griglia, sei canali, ritaglio, sovrapposizione, disegno a schermo |
| `GrigliaVerifica.cs` | L'unica verifica: macchie calde contro numeri realmente usciti |
| `Program.cs` | Scaricamento (invariato) → figure → verifica → giocata |

35 file di algoritmi precedenti portano in testa il banner `// DEPRECATO`: restano sul disco e
compilano, ma nessuno è chiamato dall'applicazione.
