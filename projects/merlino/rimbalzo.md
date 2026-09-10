# Il rimbalzo della forma, messo alla prova — e il controllo che lo boccia (10/09/2026)

> Richiesta dell'utente: *«procedi in parallelo sia per ej che per se»*, dopo la proposta di far
> rispettare alla catena l'unica cosa certificata del progetto. La misura era condizione dichiarata
> in partenza: *«misurando prima su tutte le previsioni passate se avrebbe alzato i centri — così
> non lo mettiamo dentro per fede»*.

## Cosa si voleva provare

[filo.md](filo.md) aveva certificato sull'EuroJackpot che **«decine attaccate» è anti-correlata nel
tempo** (p 0,025, protocollo a scomparto, verificata sul tratto mai usato per trovarla):
un'estrazione compatta sulle decine tende a essere seguita da una sparsa, e viceversa. È l'unico
legame fra un'estrazione e la successiva che sia mai passato dal protocollo.

L'ipotesi da provare era la conseguenza naturale: **se il rimbalzo è vero, usarlo come filtro sulle
candidate deve alzare i centri.**

## Come è stata costruita la prova

Un **quarto braccio** dentro `Catena.Esegui`, accanto a «mirate al bersaglio» e «caso puro»
(`Catena.cs`, `FiltraForma` + `MostraRimbalzo`). A ogni passo:

1. si parte dallo **stesso identico pool** di candidate plausibili della catena, con lo **stesso
   seme**;
2. si buttano via quelle che stanno dalla **parte sbagliata della media** — dove «parte giusta» la
   decide il verso: `-1` rimbalzo (opposta all'ultima), `+1` persistenza (stessa parte);
3. si sceglie con lo stesso `Blocco.Scegli`, e si contano i centri.

Due accorgimenti che decidono se la misura vale qualcosa:

- **La media è causale.** Si legge dal *catalogo*, che contiene solo le estrazioni già attraversate.
  Non guarda il futuro per costruzione, non per promessa.
- **La differenza si guarda appaiata.** Stesso passo, stesso pool, stesso seme: la sigma da usare è
  quella della differenza passo per passo, non quella dei due totali separati. Confrontare due medie
  calcolate su storie diverse avrebbe dato una sigma molto più piccola e un falso «funziona».

E soprattutto il **controllo al verso opposto**: se anche `+1` guadagna, il guadagno non è il
rimbalzo — è il filtrare in sé.

## L'esito, su cammini interi

| | braccio CATENA | rimbalzo (−1) | persistenza (+1) | caso puro |
|---|---|---|---|---|
| **SuperEnalotto**, 2.824 previsioni | 1,1640 | **1,1813** | 1,1753 | 1,1239 |
| **EuroJackpot**, 874 previsioni | 1,3078 | **1,3124** | **1,3307** | 1,2780 |

Le differenze appaiate:

| | verso −1 (il certificato) | verso +1 (il controllo) |
|---|---|---|
| **SuperEnalotto** | +0,0174 ± 0,0139 = **+1,25 σ** | +0,0113 ± 0,0137 = +0,83 σ |
| **EuroJackpot** | +0,0046 ± 0,0238 = **+0,19 σ** | +0,0229 ± 0,0244 = **+0,94 σ** |

## Il verdetto: non è il rimbalzo

**Nessuno dei quattro arriva a due sigma.** Ma il punto che chiude la questione non è questo: è che
**sull'EuroJackpot il verso SBAGLIATO guadagna cinque volte più di quello certificato** (+0,0229
contro +0,0046). Proprio sul tabellone dove il certificato esiste.

Se il rimbalzo fosse la causa del guadagno, `+1` dovrebbe **perdere**. Guadagna. Quindi ciò che
guadagna non è la direzione: è **il filtro in sé** — togliere metà pool cambia quali cinque sestine
sopravvivono a `Blocco.Scegli`, e quel poco che si guadagna è la solita leva della copertura, la
stessa già nota (meno sovrapposizione fra le cinque = più tabellone giocato).

**Il certificato del `filo` resta vero come misura e resta inutilizzabile come previsione.** Sono due
cose diverse, e questa prova serviva esattamente a non confonderle: una correlazione di −0,126 su 261
estrazioni è reale e insieme troppo sottile per spostare un conteggio di centri.

## Cosa resta nel codice

Il braccio **resta acceso** con verso `-1`, come sono rimasti «mirate» e «caso puro»: è un controllo
permanente, si rimisura da solo a ogni cammino e il verdetto è stampato nel resoconto. Si cambia
dall'esterno senza ricompilare:

```
MERLINO_FORMA="celle attaccate"   quale dimensione filtrare (vuota = braccio spento)
MERLINO_FORMA_VERSO="+1"          il controllo alla direzione opposta
```

Da rimisurare quando l'archivio EJ sarà cresciuto: 874 previsioni sono poche per una differenza di
questa taglia, e la risposta di oggi è «non si vede», non «non c'è».

## La trappola che è stata evitata

Senza il controllo al verso opposto, il resoconto avrebbe detto: *«SuperEnalotto 1,1813 contro
1,1640, l'EuroJackpot conferma, il rimbalzo funziona»* — e sarebbe finito nel modello. È lo stesso
errore già visto col 2009 e con la ricerca degli sguardi: **un criterio che non può fallire non è una
verifica.** Qui il criterio poteva fallire, ed è fallito.
