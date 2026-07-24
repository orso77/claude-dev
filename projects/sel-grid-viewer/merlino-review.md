# SelGridViewer — Analisi Merlino (predizione 0 numeri)

Data: 2026-04-10
Repo: `C:\src\orso\SelGridViewer`
File chiave:
- `MerlinoEngine.cs` — motore predittivo S7 "Wider Funnel"
- `MerlinoAutoTuner.cs` — tuner parametri
- `Form1.cs` — integrazione UI, cache predizione, rendering griglia
- `LottoRow.cs` — DTO estrazione
- `MerlinoModelParams.cs` / `MerlinoModelCache.cs` / `MerlinoModelStore.cs`

## Sintomo riportato
> "L'algoritmo predittivo non indovina nemmeno 1 numero."

## Pipeline attuale (com'è adesso)

### Caricamento dati
`Form1.cs:712` — `records = records.OrderByDescending(ExtrDate)` → `records[0]` = estrazione più recente (DESC).

### Costruzione engine
`Form1.cs:187-188`:
```csharp
var engine = new MerlinoEngine(records);   // records DESC
_merlinoPred = engine.Predict();
```

`MerlinoEngine` ctor (`MerlinoEngine.cs:35-42`):
```csharp
_recordsAsc = recordsDesc.AsEnumerable().Reverse().ToList();
```
→ `_recordsAsc[^1]` = estrazione più recente.

### Scelta della "lastRow"
`MerlinoEngine.cs:182-183`:
```csharp
var lastRow = _recordsAsc[^1];                         // estrazione più recente
var lastNums = lastRow.GetNumbers()...;
```

Merlino calcola i punteggi a partire dai numeri dell'ULTIMA estrazione conosciuta e predice la PROSSIMA (ancora da estrarre).

### Anti-repeat
`MerlinoEngine.cs:186-204`:
```csharp
var lastSet = new HashSet<int>(lastNums);
var prevSet = ...;
// ...
for (int y = 1; y <= K; y++)
{
  if (lastSet.Contains(y))  crossBlockScore[y] *= 0.1;
  else if (prevSet.Contains(y)) crossBlockScore[y] *= 0.5;
}
```
I numeri dell'ultima estrazione vengono **penalizzati pesantemente** (×0.1) per evitare che vengano ri-predetti.

### Cache + rendering
`Form1.cs:177-189` — `EnsurePronosticoCache` costruisce la predizione **una sola volta** e la tiene in cache fino a che non si tocca il dataset.
`Form1.cs:765-798` — quando `merlinoActive` è ON, la griglia colora Top6/Top18/SS **sempre con la stessa predizione**, a prescindere da `currentIndex`.

## BUG CRITICO #1 — Disallineamento temporale (target vs train)

**Ecco perché si vedono zero match:**

1. L'utente scorre le estrazioni con `currentIndex` (vedi `DisplayCurrentRecord`).
2. `records[currentIndex]` è l'estrazione che l'utente sta **visualizzando**.
3. Merlino però è calcolato **una volta sola** su TUTTI i records, con `lastRow = _recordsAsc[^1] = records[0]`.
4. Quindi Merlino sta predicendo la **prossima estrazione ancora da estrarre** (quella che non c'è nel dataset).
5. Quando l'utente è su `currentIndex = 0` (la più recente), la griglia confronta visivamente la predizione con `records[0]`, ma Merlino esclude per costruzione i numeri di `records[0]` (anti-repeat ×0.1).
6. Quando l'utente naviga su `currentIndex = X > 0`, la griglia mostra **sempre la stessa predizione cachata** (quella per il "futuro"), quindi non c'è alcun motivo per cui debba matchare una estrazione passata.

**Risultato operativo**: zero o quasi-zero hit sistematici, esattamente quello che riporta l'utente.

### Fix proposto (conceptuale)
La predizione visualizzata deve dipendere da `currentIndex`:
- Quando l'utente visualizza `records[currentIndex]`, Merlino deve essere addestrato sui records **precedenti** (`records[currentIndex+1 .. end]` in versione DESC, o equivalentemente `recordsAsc[0 .. count-1-currentIndex]`).
- `lastRow` diventa la PRIMA estrazione disponibile prima di quella visualizzata (cioè `records[currentIndex+1]`).
- La predizione viene confrontata con `records[currentIndex]` → questa è una **walk-forward evaluation** corretta.

Due modalità possibili:
1. **Modalità "prossima estrazione"** (mantieni comportamento attuale): predizione fissa per il futuro ignoto, **senza** sovrapporre colori alla griglia dell'estrazione visualizzata (che è una estrazione nota, diversa).
2. **Modalità "backtest"**: ricalcola Merlino a ogni `currentIndex` usando solo lo storico precedente e mostra i match effettivi sulla griglia.

La modalità 2 è quella utile per capire se Merlino funziona davvero.

### Implementazione fix #1 (sketch, da validare)
- Invalidare la cache in `DisplayCurrentRecord` quando `currentIndex` cambia (oppure cache key = `currentIndex`).
- In `EnsurePronosticoCache` passare a `MerlinoEngine` il sotto-insieme `records.Skip(currentIndex + 1).ToList()` (DESC).
- Opzionalmente tenere la cache in un `Dictionary<int, MerlinoPrediction>` per non ricalcolare ogni volta.

Nota perf: `MerlinoEngine` costruisce cross-block / successor / DNA su tutto lo storico. Su ~2000+ estrazioni è O(N·6·3) per crossblock: ~36k op — trascurabile. Si può ricalcolare per ogni `currentIndex` senza problemi.

## BUG CRITICO #2 — MerlinoAutoTuner non tuna MerlinoEngine

`MerlinoAutoTuner.cs:142-149`:
```csharp
var model = new ProbabilitaLotto(
  pastDesc,
  alpha: p.Alpha,
  halfLife: p.HalfLife,
  pesi: (p.WFreq, p.WRecency, p.WDelay, p.WZscore, p.WStabilityPenalty),
  zScale: p.ZScale,
  useSqrtForDelay: p.UseSqrtForDelay,
  renormalizeWeights: true);

var predicted = model.GetTopNumeri(6).ToArray();
```

Il tuner fa walk-forward su `ProbabilitaLotto` (il modello vecchio), **non** su `MerlinoEngine`. I `MerlinoModelParams` ottimizzati non vengono mai usati da `MerlinoEngine` (che è un'euristica senza parametri). Di conseguenza:
- La hit-rate mostrata nello status bar (`Merlino>=4: xx%`) misura `ProbabilitaLotto`, non Merlino.
- Il "tuning Merlino" visto dall'utente non ha alcun effetto su ciò che Merlino predice.

**Fix**: rendere `MerlinoEngine` parametrizzabile oppure scrivere un `EvaluateWalkForward` dedicato che instanzia `MerlinoEngine` e calcola i match. Dato che `MerlinoEngine` attuale è fisso, il tuner di fatto non serve — va **disabilitato** o **ricablato**.

## BUG #3 — `_totalAppearances[x]` include l'ultima riga

`MerlinoEngine.cs:52-63`:
```csharp
for (int i = 0; i < _recordsAsc.Count; i++)
{
  var nums = _recordsAsc[i].GetNumbers();
  foreach (var x in nums)
  {
    _totalAppearances[x]++;                             // sempre incrementato
    for (int step = 1; step <= 3 && i + step < _recordsAsc.Count; step++)
    {
      ...
      _crossBlock[x, y]++;
    }
  }
}
```

Per l'ultima riga (i = count-1), si incrementa `_totalAppearances[x]` ma il `for (step)` non entra mai → numeratore 0, denominatore 1 in più. Per le penultime (i = count-2, count-3) c'è asimmetria simile.

Impatto: sottostima dei cross-block dei numeri dell'ultima estrazione, ma visto che quei numeri sono comunque penalizzati dall'anti-repeat, l'impatto sul ranking è marginale.

**Fix minimo**: fare il loop esterno fino a `_recordsAsc.Count - 3` oppure normalizzare per il numero effettivo di "opportunità di cross" per ciascun x, non per il totale appearances.

## BUG #4 — DNA score può essere tutto zero → ordering degenerato

`MerlinoEngine.cs:215-235`:
```csharp
var top18 = top24
  .OrderByDescending(y => dnaScore[y])
  .Take(18)
  .ToList();
```

Se per il DNA corrente (anche fuzzy) non ci sono match nel dizionario, `dnaScore[y] = 0` per tutti → `OrderByDescending` diventa stabile sulla sorgente `top24`, quindi top18 = primi 18 di top24 nell'ordine del `Enumerable.Range`. Di fatto il livello 2 diventa no-op.

**Fix**: fallback esplicito (es. usare lo score CrossBlock normalizzato come tiebreaker) o loggare un warning quando `dnaMatches == 0`.

## BUG #5 — Successor Top-6 può degenerare

Stesso problema di sopra: se `successorScore` è a zero per i 18 numeri selezionati (perché nessuno dei 6 numeri dell'ultima estrazione è mai stato "sorgente" di quei 18 come immediato successore), top6 = primi 6 di top18 ordinati. Rileggere le statistiche per vedere se succede davvero sul dataset reale.

## Problema concettuale di fondo

Il Superenalotto è un processo indipendente e quasi uniformemente distribuito. **Nessun modello markoviano basato su co-occorrenze storiche** può produrre un hit-rate significativamente superiore al random (1.2 hit attesi per top-18). Aspettative realistiche:

| Selezione | Hit attesi (random) | P(0 hit) |
|-----------|---------------------|----------|
| Top-6     | 0.40                | ~66%     |
| Top-18    | 1.20                | ~28%     |
| Top-24    | 1.60                | ~18%     |

Quindi vedere "0 hit" su una singola estrazione NON è di per sé un bug se siamo sul top-6 (è lo scenario più probabile). Sul top-18 dovrebbe capitare solo nel 28% dei casi: se capita sempre, quello SÌ è un bug (e il bug #1 lo spiega).

## Proposta di roadmap

Ordine suggerito di intervento (minimal-diff, nessuna riscrittura):

1. **Fix bug #1** — cache per `currentIndex`, rebuild engine sui soli records precedenti, permettere backtest visivo coerente. **Priorità massima**: è l'unica cosa che spiega "0 hit sempre".
2. **Diagnostica** — dopo il fix #1, verificare su N=200 estrazioni storiche: qual è il tasso medio di hit di top-18? Se ~1.2 siamo al livello random (atteso). Se molto sotto 1.2, c'è un bias negativo introdotto dall'euristica.
3. **Decidere Merlino tuner** — o lo si cabla davvero su `MerlinoEngine` (parametrizzandola), o lo si rimuove/rinomina. Attualmente inganna l'utente mostrando metriche su un altro modello.
4. **Micro-fix #3** sul denominatore `_totalAppearances` (opzionale, impatto minimo).
5. **Fallback DNA/Successor** (#4, #5) — solo se dopo i fix precedenti il ranking continua ad avere comportamento degenere.
6. **Gestione aspettative** — aggiungere in UI l'atteso random (1.2 per top-18) come baseline, così l'utente vede se Merlino batte davvero il caso o no.

## Azioni da confermare con l'utente

- Qual è l'obiettivo reale di Merlino: predire la **prossima** estrazione (modalità 1) o fare **backtest** interattivo sulle estrazioni passate (modalità 2)? O entrambi?
- Quando dice "non indovina 1 numero", si riferisce a top-6 o top-18? (top-6 = 0 hit è normale ~66% delle volte).
- Si può disabilitare/rimuovere `MerlinoAutoTuner` e `MerlinoModelParams` (non usati da `MerlinoEngine`), o bisogna mantenerli per retrocompatibilità cache su disco?

## Note operative
- Nessuna modifica al codice è stata applicata in questa sessione. Questo file è solo analisi.
- Le istruzioni di progetto (`C:\!claude\CLAUDE.md`) prevedono minimal-diff e niente refactor senza richiesta esplicita: attendere conferma utente prima di toccare `MerlinoEngine.cs` o `Form1.cs`.
