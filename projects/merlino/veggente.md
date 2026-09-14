# Veggente — il banco del passato (14/09/2026)

Programma nuovo e separato: `C:\src\orso\Veggente` (.NET 10). Legge l'archivio di Merlino in sola
lettura; di Merlino non tocca nulla.

## La richiesta, con le parole dell'utente

- «devi ricominciare tutto da capo» → programma nuovo, nessun codice di Merlino riusato
- «devi assolutamente trovare un modo per predire le estrazioni» / «fai come ti pare» → i tre giri qui sotto
- «devi basarti solo sul passato. devi simulare le estrazioni sul passato e trovare un metodo che
  indovini le estrazioni passate. è quello il vero banco di prova. nessuna estrazione futura» →
  il banco

## Il banco

- Per ogni estrazione passata `t` ogni metodo vede solo `[0, t)` e mette in classifica i numeri.
- Si contano i centri nei primi K (giocata piccola: 6 SE / 5 EJ) e nei primi 5K (giocata grande:
  cinque giocate disgiunte, 30 SE / 25 EJ). Attesa di chi non sa nulla: 0,400 e 2,000 (SE), 0,500 e
  2,500 (EJ). Sigma dalla varianza ipergeometrica esatta.
- **Ricerca** = primo 70% (SE 20/02/2010 → 11/06/2022, 1.909 estrazioni; EJ 13/03/2015 → 16/04/2024,
  578). **Sigillato** = ultimo 30% (SE 819, EJ 249): passato, ma mai guardato per scegliere.
- SE dal 01/07/2009 (2.828 estrazioni, prime 100 di ambientamento); EJ dal 28/03/2014 (877, prime 50).
- Pari merito spezzati da un rumore fisso per (t, numero), uguale per tutti i metodi.

**Taratura** (`Veggente.exe prova`): storia finta con una regola nascosta nel 25% delle estrazioni
(un numero è il vicino +1 di uno dell'ultima). Il banco la trova: +9,35 σ in ricerca, +6,56 σ sul
sigillato; la trovano anche i due metodi che imparano (+6,88 / +6,45 σ), il coro e il comitato.

## I tre giri

1. **143 varianti di base** (ogni metodo nei due versi): frequenze su 16 finestre, ritardo e ritardo
   sul proprio passo, uscito L fa (1-10), chi segue a distanza 1-3 (anche a memoria corta), coppie
   con l'ultima, vicini di 1 e di 10, specchio, decina e cifra finale, Jolly e SuperStar dell'ultima,
   analoghi dell'ultima; **secondo giro**: stesso giorno della settimana, ritorno a passo 2-14,
   frequenza contando anche il Jolly (7 palline dell'urna), stesso mese negli anni prima; due
   **apprendisti** su 16 misure (logistica, conteggio per fasce).
2. **Scelti in ricerca, provati sul sigillato**: crollano sempre. SE: +2,75 σ → +0,55 σ (6 numeri),
   +2,29 σ → −0,53 σ (30). EJ: +2,46 σ → −0,74 σ (5), +3,07 σ → +1,33 σ (25). Nel SE il «caso»
   stesso sta a +0,83 σ in ricerca: lì la classifica è rumore.
3. **Metodi che scelgono o imparano da soli** (nessuna scelta fatta a mano, valgono su tutto il
   tratto): «segui il migliore» (tutta la storia, ultime 50/200/500), **coro** (logistica e fasce sui
   posti in classifica di tutti i metodi), comitato dei 10 migliori.

## Il candidato: «segui il metodo migliore finora», giocata grande

| | ricerca | sigillato | tutto |
|---|---|---|---|
| SE, 30 numeri | +1,55 σ | **+2,40 σ** | **+2,61 σ** (2,056 centri contro 2,000) |
| EJ, 25 numeri | +2,37 σ | +1,33 σ | **+2,71 σ** |

Anche il coro con la logistica, sul SE a 30 numeri: +1,63 / +2,06 / +2,49 σ.
Sulla giocata piccola nessuno dei due tiene.

### La verifica sul caso (200 storie casuali per gioco, `Veggente.exe nullo <seme>`)

Stesse date, estrazioni tutte a caso, stesso banco intero.

- **Il banco non gonfia**: sul caso tutti i metodi che scelgono da soli stanno a media ~0, sd ~1.
- «segui il migliore finora», giocata grande: il caso raggiunge il valore vero **2 volte su 200 sul
  SE** (anche sul solo sigillato: 2 su 200) e **0 su 200 sull'EJ**.
- Contando che i metodi di questo tipo sono 7: il migliore dei 7 arriva lì per caso **10 su 200
  (SE)** e **4 su 200 (EJ)**. Che sia **lo stesso metodo** a primeggiare in due giochi separati pesa
  a favore.
- Coro logistica SE giocata grande: 1 su 200 (tutto), 7 su 200 (sigillato).

**Stato: candidato, non risultato.** Tre giri costruiti uno dopo l'altro guardando gli esiti; la
verifica sul caso copre il banco ma non le mie scelte di disegno fra un giro e l'altro. E la taglia è
piccola: +0,056 centri su 30 numeri a estrazione (+2,8%).

## Prossimo passo — la replica sul Lotto, criterio scritto PRIMA di lanciarla

Provare il candidato **fermo com'è** su dati che il banco non ha mai toccato: le **ruote del Lotto**
dal 01/07/2009 (passato anche quelle). Se il vantaggio è della macchina e non del caso, deve
comparire anche lì.

Criterio fissato prima di vedere un solo numero del Lotto (14/09/2026):

- metodo: **«segui il metodo migliore finora (tutta la storia)»**, **giocata grande** (25 numeri su 90,
  cinque cinquine disgiunte), colonna **«tutto»**; nessuna modifica al banco né ai metodi di base;
- ogni ruota è una prova indipendente; si riporta la sigma di ogni ruota e la **sigma combinata**
  (somma delle sigma diviso radice del numero di ruote);
- **conferma** = sigma combinata ≥ +2 e più di metà delle ruote positive;
- **smentita** = sigma combinata sotto +1: in quel caso il +2,6 σ del SuperEnalotto va letto come
  caso, e si dice.
- Tutto il resto (coro, altri metodi, giocata piccola) si riporta come osservazione, non come prova.

### Esito della replica: SMENTITA (14/09/2026, dopo il commit `cd08091` che fissava il criterio)

11 ruote, 2.793 estrazioni ciascuna (02/07/2009 → 20/06/2026), banco e metodi invariati.

| ruota | ricerca | sigillato | **tutto** |
|---|---|---|---|
| BA | +0,49 | +0,67 | +0,78 |
| CA | +0,85 | −0,15 | +0,62 |
| FI | −0,02 | −0,15 | −0,10 |
| GE | −0,50 | −0,40 | −0,64 |
| MI | −0,35 | −0,01 | −0,30 |
| NA | −0,40 | +0,89 | +0,15 |
| PA | −0,35 | −0,87 | −0,77 |
| RM | −0,52 | +1,39 | +0,33 |
| RN | −0,57 | +0,96 | +0,05 |
| TO | +1,39 | −0,01 | +1,16 |
| VE | +0,14 | −1,30 | −0,60 |

**Sigma combinata +0,21, positive 6 su 11** → sotto +1: per il criterio scritto prima, il +2,6 σ del
SuperEnalotto e il +2,7 σ dell'EuroJackpot vanno letti come **caso**.
Osservazioni (non prove): giocata piccola combinata −1,71; coro logistica +0,76; coro fasce +0,17;
segui le ultime 500 +0,14.

**Chi seguiva, e perché non c'era un meccanismo**: sul SE a 30 numeri il capo è cambiato fra famiglie
che non hanno nulla in comune — cifra finale nelle ultime 20 (1.002 estrazioni), ritorno a passo 9
(899), frequenza nelle ultime 1000 (600); sull'EJ a 25 numeri quasi sempre ritorno a passo 10 ↓
(655). Un vantaggio della macchina avrebbe portato a una famiglia sola e ricorrente nei giochi.

### Cosa resta di questa giornata

- Un banco del passato **tarato** (vede una regola nascosta nel 25% delle estrazioni) e **pulito**
  (sul caso tutti a zero): è lo strumento, e resta.
- 150 metodi, 3 giri, 2 giochi, 11 ruote: nessuno indovina le estrazioni passate più del caso in
  modo che si ripeta su dati non guardati.

## Ritorni — strutture che tornano in più estrazioni (criterio scritto PRIMA di lanciare)

Richiesta (14/09/2026): *«continua a cercare qualcosa che ritorni in più estrazioni»*.

Non un numero da giocare ma una **struttura**: se in una parte della storia compare più (o meno) del
dovuto, deve farlo anche nell'altra. `Veggente.exe ritorni`:

- **11 famiglie**: ogni pallina, coppie, terne, chi segue chi a distanza 1/2/3, distanze fra i numeri,
  valore del 1°..K° numero, forma (pari × consecutivi × decine), numeri in comune con le due
  estrazioni dopo, somma;
- **2 modi di dividere**: metà contro metà; blocchi alterni da 50 (per ciò che dura poco);
- **13 serie**: SE, EJ, 11 ruote del Lotto; + fra le ruote lo stesso giorno e il giorno dopo;
- ogni misura contro **100 storie a caso** delle stesse dimensioni → sigma;
- **tarature**: storia finta con 9 palline più pesanti del 25%, storia finta con il 7 che trascina
  l'8 nella metà dei casi. Devono accendere «numeri» e «coppie»; se non lo fanno lo strumento è rotto.

**Criterio**: una famiglia **torna** se (a) la sigma combinata delle 11 ruote è ≥ +3 in entrambi i
modi, oppure (b) SE ≥ +2, EJ ≥ +2 e Lotto combinato ≥ +2 nello stesso modo. Fra le ruote: ≥ +3.
Chi torna diventa un metodo e passa dal banco del passato; chi non torna va a verbale.

### Esito del primo giro dei ritorni: NESSUNA famiglia torna (commit del criterio `2510d4c`)

Tarature accese come dovevano: 9 palline più pesanti del 25% → «numeri» +4,56 σ (e «chi segue chi»
fino a +6,96, perché le palline pesanti si seguono fra loro); il 7 che trascina l'8 → «coppie» +7,27 σ,
«terne» +5,83 σ. Risoluzione quindi: un peso del 25% su 9 palline si vede a ~4-5 σ con 2.828
estrazioni.

| famiglia | SE metà | EJ metà | Lotto comb. metà | SE blocchi | EJ blocchi | Lotto comb. blocchi |
|---|---|---|---|---|---|---|
| numeri | −0,19 | +0,21 | −0,93 | −0,06 | −1,38 | +0,64 |
| coppie | +0,28 | −1,68 | +0,34 | −0,07 | −1,97 | −0,35 |
| terne | +0,86 | −2,21 | +1,71 | +1,04 | −1,64 | +1,09 |
| segue a 1 | +0,62 | +1,41 | −0,53 | −0,37 | −0,47 | −0,64 |
| segue a 2 | +0,21 | −0,40 | +0,09 | +0,65 | −1,69 | +0,39 |
| segue a 3 | −0,95 | +0,78 | −0,42 | −0,44 | −0,39 | −0,20 |
| distanze | +0,75 | +0,83 | −1,94 | +1,78 | −0,10 | −0,75 |
| valore 1°..K° | +0,61 | +0,09 | −0,57 | −0,90 | −1,55 | −0,53 |
| forma | −1,43 | +1,00 | +0,57 | −0,87 | −0,90 | −0,69 |
| in comune con le 2 dopo | +1,21 | +1,05 | +0,95 | +0,90 | +1,02 | +1,20 |
| somma | +1,78 | +0,55 | +0,88 | +1,07 | −1,41 | +0,19 |

Fra le 11 ruote (2.793 giorni): stesso numero su più ruote lo stesso giorno −0,36 σ (42.612 contro
42.687 attesi); il giorno dopo su un'altra ruota −0,92 σ; quali numeri coincidono, metà contro metà,
−1,40 σ. Nessun valore vicino al criterio. Da notare solo come osservazione: «in comune con le due
dopo» è positivo in tutte e sei le caselle, ma sempre fra +0,90 e +1,21.

### Secondo giro dei ritorni — stesso criterio, scritto prima

Famiglie nuove: chi segue chi a distanza lunga (4-10 insieme, 11-50 insieme); dopo quante estrazioni
torna esattamente un numero (profilo dei ritorni 1-100); pallina × giorno della settimana; pallina ×
mese; **SuperEnalotto contro Lotto** (macchine diverse, stessi giorni): stesso giorno e giorno dopo.
Criterio invariato: Lotto combinato ≥ +3 in entrambi i modi, oppure SE, EJ e Lotto ≥ +2 nello stesso
modo; incroci SE-Lotto ≥ +3. Le famiglie del primo giro si rimisurano ma non contano come prova
nuova.

## File

| File | Ruolo |
|---|---|
| `Storia.cs` | lettura archivio, cumulati e matrici che vedono solo `[0, t)`, storie finte |
| `Predittori.cs` | i metodi di base |
| `Apprendista.cs` | logistica e conteggio per fasce su 16 misure |
| `Coro.cs` | combinazione appresa di tutti i metodi sui posti in classifica |
| `Program.cs` | il banco: ricerca, sigillato, metodi che scelgono da soli, giocata, CSV |

```
Veggente.exe               SuperEnalotto
Veggente.exe ej            EuroJackpot
Veggente.exe prova [ej]    taratura su storia finta con regola nascosta
Veggente.exe nullo <seme>  storia tutta a caso (CSV in C:\!!claude-temp\veggente-nullo)
```
