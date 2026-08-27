# L'affinamento a colpo sicuro — `Merlino.exe affina [ej]` (27/08/2026)

## La procedura chiesta dall'utente, eseguita alla lettera

Dopo lo zero della giocata del 25/08, la proposta dell'utente: *«ricomincerei da capo, prenderei il
primo anno di estrazioni e inizierei a osservare, poi farei una predizione e continuerei ad
affinarla finché non mi dà almeno un 4 su quella successiva. Poi passo a quella successiva ancora e
la correggo e ritocco finché non dà un 4. E poi quella dopo ancora, a partire dal famoso 2009. Alla
fine riuscirai a creare un sistema predittivo, no?»* — un tuning che impara da tutte le estrazioni
e da tutti gli errori storici, e che deve diventare sempre più preciso col passare del tempo.

Costruito in `Affina.cs`:

1. **si riparte da capo**: un peso per numero, niente catena, niente tavole;
2. **il primo anno (02/07/2009–01/07/2010, 157 estrazioni) si osserva soltanto**: i pesi partono
   dalle sue frequenze, normalizzate;
3. **predizione** = i 6 numeri col peso più alto;
4. **ritocco finché non becca il 4**: si riassegna a caso il peso di un numero a caso (intervallo
   fisso) e si tiene la mossa se i centri sull'estrazione in corso non peggiorano (salita di
   collina con mosse a parità); si insiste finché la predizione non fa almeno 4 centri;
5. **si avanza** alla successiva portandosi dietro tutti i pesi corretti, fino a oggi: 2.661 passi.

**La misura di funzionamento** (dichiarata prima di partire): il ritocco usa l'estrazione già
uscita, quindi il 4 sul passato arriva per costruzione e non è lui la misura. La misura è il
**primo colpo** — i centri della predizione su ogni estrazione PRIMA di qualunque ritocco su di
essa — e i **ritocchi necessari**: se le correzioni accumulate insegnano, il primo sale e i secondi
scendono lungo gli anni.

## Due tarature sbagliate, corrette lungo la strada

- **Accettazione solo-se-migliora**: la salita di collina si incaglia appena il sesto peso più
  alto è già un numero uscito (ogni mossa che riordina senza migliorare viene rifiutata): metà dei
  passi non raggiungeva il 4 in 200.000 ritocchi. Corretta tenendo le **mosse a parità**.
- **Intervallo di riassegnazione = 1,1 × massimo corrente**: le mosse neutre fanno collassare la
  scala verso zero; dal 2016 tutti i pesi erano uguali, la predizione degenerava in `01 02 03 04
  05 06` e il 4 non arrivava più. Corretto con **scala fissa** (pesi normalizzati all'anno di
  osservazione, riassegnazione in [0; 1,1]).

## Il registro del cammino fedele (run 27/08/2026)

| anno | passi | primo colpo medio | ritocchi medi | primi colpi ≥3 | ≥4 |
|---|---|---|---|---|---|
| 2010 | 78 | 0,359 | 1.126 | 1 | 0 |
| 2011 | 157 | 0,389 | 1.248 | 1 | 0 |
| 2012 | 156 | 0,404 | 1.258 | 0 | 0 |
| 2013 | 157 | 0,414 | 1.282 | 0 | 0 |
| 2014 | 156 | 0,327 | 1.168 | 0 | 0 |
| 2015 | 157 | 0,401 | 1.188 | 0 | 0 |
| 2016 | 157 | 0,446 | 1.122 | 1 | 0 |
| 2017 | 156 | 0,423 | 1.190 | 0 | 0 |
| 2018 | 156 | 0,301 | 1.079 | 0 | 0 |
| 2019 | 157 | 0,382 | 1.177 | 0 | 0 |
| 2020 | 139 | 0,417 | 1.164 | 2 | 0 |
| 2021 | 156 | 0,436 | 1.201 | 2 | 0 |
| 2022 | 157 | 0,389 | 1.280 | 0 | 0 |
| 2023 | 182 | 0,363 | 1.171 | 0 | 0 |
| 2024 | 208 | 0,385 | 1.199 | 0 | 0 |
| 2025 | 196 | 0,413 | 1.246 | 1 | 0 |
| 2026 | 136 | 0,279 | 1.182 | 1 | 0 |

**Complessivo su 2.661 passi**: primo colpo medio **0,386** (una combinazione qualunque: 0,400);
prima metà del cammino 0,398, seconda metà 0,376. Istogramma del primo colpo:
0:1778 · 1:749 · 2:125 · 3:9 · 4:0. I primi colpi ≥3 sono 9, contro ~8 attesi per puro caso.

## Il verdetto, voce per voce

- **Il 4 su ogni estrazione passata**: raggiunto sempre, 2.661 su 2.661 — per costruzione.
- **Il primo colpo non sale**: piatto a 0,39 ± rumore per sedici anni, seconda metà sotto la
  prima. Dopo 2.600 estrazioni di correzioni accumulate, la predizione sull'estrazione nuova vale
  esattamente quanto nel 2010, cioè quanto sei numeri qualunque.
- **I ritocchi non scendono**: ~1.100–1.280 costanti dal 2010 al 2026. Se il tuning imparasse,
  beccare il 4 dovrebbe diventare via via più facile: non lo diventa mai.
- **La funzione che emerge memorizza, non predice.** La dimostrazione più plastica è la
  predizione finale del cammino: `34 36 49 67 69 70` — contiene 36, 67, 69, 70, cioè
  **esattamente il 4 dell'ultima estrazione su cui è stata ritoccata** (25/08: 15 36 62 67 69 70).
  Il sistema non ha imparato la regola delle estrazioni: ha copiato l'ultima risposta del compito.

È la conferma sperimentale della distinzione: *descrivere* tutto il passato è sempre possibile
(infinite funzioni lo fanno, e questa procedura ne costruisce una, garantito); *predire* la
prossima richiede che il meccanismo porti memoria da un concorso all'altro — e su quel canale il
primo colpo resta la misura, e resta a 0,40.

## File toccati (sorgente, NON committato — serve autorizzazione)

- `Affina.cs` (nuovo): la procedura, con seme deterministico per passo (`SemeDelPasso`).
- `Program.cs`: aggancio del comando `affina` / `affina ej` (l'EJ usa 5 numeri su 50, stesso
  obiettivo 4, non ancora eseguito).
