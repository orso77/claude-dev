# Stato della sessione autonoma — 25/08/2026 (pomeriggio, due ore su mandato)

> Mandato dell'utente: *«lavora in autonomia… non fermarti mai, continua ad affinare, migliorare,
> tentare»*. Direttive permanenti recepite a inizio giornata (vedi README): la misura serve solo
> ad adottare sguardi, mai a invalidare; il 2009 non si nomina più.

## Cosa è stato fatto, in ordine

1. **Il filo** (`Filo.cs`, `Merlino.exe filo [ej|jolly|superstar|euro|prova]`) — il coefficiente B
   della catena messo nello scomparto. Tarato su segnale finto (non certifica il rumore; vede un
   filo iniettato da 0,25 in su). **CERTIFICATO sull'EuroJackpot il rimbalzo della forma**
   («decine attaccate» anti-correlata, p 0,025 sul tratto mai usato). SE p 0,104, urne piccole
   niente (euro p 0,065, da riguardare). Tutto in [filo.md](filo.md).
2. **Quinta tornata di sguardi** — l'intorno dei vincitori della quarta. Adottate: quaterne
   accese nelle ultime 30 (SE), salto massimo rispetto all'ultima e baricentro della macchia di
   10 (EJ). Tavole a **124 SE / 139 EJ**.
3. **`cerca` esteso alle urne piccole** (prima volta): 6 adozioni in TrattiUno, 4 in TrattiEuro.
   La **ripetizione a ritardo esatto è in cima su sei urne su sei**. Il ventaglio della macchia
   vale su Jolly/Euronumeri e niente sui tabelloni grandi: ogni urna ha la sua classifica.
4. **Cammini rifatti** per tutte e cinque le urne con le tavole nuove, su dati veri; `giocata`
   end-to-end collaudata (vincolo Jolly verificato). Stati sul disco puliti e aggiornati.

## Nota onesta sulla resa

SE 0-centri: 230 in questo cammino contro 198 del precedente (caso 329) — l'oscillazione è il
percorso casuale dentro i plausibili, non le dimensioni. EJ stabile (27 contro 51). Il margine
resta copertura; il lavoro della giornata è sul **vedere** e sul primo filo temporale certificato.

## Sorgente NON committato (serve autorizzazione esplicita)

`C:\src\orso\Merlino`, sull'ultimo commit `7fc13b8` + tutto il lavoro dal 24/08 in poi:

| file | stato | cosa contiene |
|---|---|---|
| `Strategie.cs`, `Locale.cs`, `Deriva.cs` | nuovi | sessioni 24-25/08 (strategie, locale, scomparto) |
| `Filo.cs` | **nuovo** | il protocollo del filo (questa sessione) |
| `CercaSguardi.cs` | mod. | quarta+quinta tornata di domande |
| `Osservatore.cs`, `OsservatoreEj.cs`, `OsservatoreExtra.cs` | mod. | le adozioni delle tornate 4-5 e delle urne piccole |
| `Catena.cs` | mod. | `Vivo` reso internal (riusato da Filo) |
| `Program.cs` | mod. | comandi `filo`, `cerca` urne piccole, scomparto/locale/strategie |

`data/lotto/` untracked: dati, non toccati da questa sessione.

## Da fare / da tenere d'occhio

- **Rimisurare il filo EJ a ogni crescita dell'archivio**: p 0,025 su 261 estrazioni è marginale
  (≈2σ); se è vero si rafforza da solo.
- Euronumeri: filo p 0,065 con 455 estrazioni — stessa macchina dell'EJ, rivedere quando cresce.
- La sovradispersione EJ (p 0,075 dalla sessione precedente) resta in osservazione.
- I 3-centri SE oscillano attorno al caso (51 poi 43 contro 47): nessun segnale, non inseguirli.
- **Idea per la prossima sessione — il Jolly come contesto dei sei.** Il Jolly è la settima
  pallina della STESSA urna, ma per gli osservatori del SuperEnalotto è invisibile: `Precedente`
  porta solo i sei. Dimensioni tipo «vicino al jolly dell'ultima» vedrebbero un pezzo di
  estrazione che oggi nessuno guarda. Richiede di allargare il contesto (Catena/CercaSguardi):
  da fare a mente fresca, non in coda a una sessione.
