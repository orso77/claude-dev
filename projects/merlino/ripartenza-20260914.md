# Ripartenza da capo (14/09/2026)

Richiesta dell'utente, con le sue parole:

- «devi ricominciare tutto da capo»
- «devi assolutamente trovare un modo per predire le estrazioni»
- «fai come ti pare ma devi trovarlo»
- «io ti ho dato tutte le indicazioni possibili»

## Premessa, detta una volta

Nessuno ha un metodo noto per predire un'estrazione fatta con macchine ad aria certificate: non
si puo' promettere di trovarlo. La promessa che si puo' mantenere e' un'altra: **non dichiarare
«trovato» nulla che non abbia retto su estrazioni uscite DOPO che il metodo e' stato congelato.**

## Fatti verificati prima di ripartire

| fatto | fonte |
|---|---|
| SE dal 01/07/2009: estrazione propria, ADM + Sisal, piazza Mastai a Roma; **due macchine a mescolamento pneumatico**, una per sestina e Jolly, una per il SuperStar | [sisal.com](https://www.sisal.com/offerta/giochi/lotterie/superenalotto/estrazione) |
| EJ: Helsinki, macchina **Venus** per i 5 numeri e **Opale** per gli Euro, ad aria; macchine controllate da VTT | [casinohelsinki.fi](https://casinohelsinki.fi/en/games/eurojackpot-eng/), [Wikipedia](https://en.wikipedia.org/wiki/Lottery_machine) |
| Oggi il SE si estrae **4 volte a settimana** (mar, gio, ven, sab; nel 2026: 34-36 per giorno fino a settembre) | archivio locale `data/2024-2026.txt` |
| Archivio locale: **2.828 estrazioni SE dal 01/07/2009** (la prima è del 02/07/2009), **877 EJ dal 28/03/2014** (l'archivio EJ parte da lì, non dal 2012). In chat era stato detto 2.881: sbagliato, il conteggio includeva le righe d'intestazione dei file | conteggio sui file, verificato con due metodi |
| **Ordine di estrazione del SE**: nessuna fonte ufficiale trovata. La pagina ADM `enalotto_estr` restituisce solo navigazione; franknet.altervista.org pubblica le sestine **ordinate**; l'unico file «in ordine di estrazione» (forum LottoCED) e' dichiarato dall'autore **generato con AI** e non affidabile | verificato il 14/09 |

## L'esito della giocata del 12/09

Estrazione SE del 12/09/2026 (concorso 147), letta sulla pagina sorgente: `03 07 14 40 78 81`,
**Jolly 01, SuperStar 54**. (Nella chat del 14/09 era stato riportato Jolly 54 / SuperStar 01:
sbagliato, nel markup il numero precede la propria etichetta. Anche il riassunto automatico di
WebFetch aveva invertito i due.)

| sestina giocata | centri |
|---|---|
| `04 14 25 34 56 59` | 1 (14) |
| `03 42 58 71 78 90` | 2 (03, 78) |
| `21 36 53 66 69 77` | 0 |
| `22 29 37 57 67 88` | 0 |
| `17 20 24 61 75 87` | 0 |
| singola `01 28 33 36 53 85` | 0 |

Sulle cinque disgiunte: 3 dei 6 numeri usciti cadono nei 30 coperti (attesa per copertura: 2,0).
La seconda sestina fa **2 punti**, che nel concorso 147 pagavano **4,69 €** (423.731 vincitori;
quote da [AGIMEG](https://www.agimeg.it/superenalotto-vincite-12-settembre-2026-4-stella-jackpot/),
la pagina Sisal non ha risposto). Un'estrazione sola non dice nulla sulla catena: e' il primo punto
del registro in avanti.
