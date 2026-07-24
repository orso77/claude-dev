# Contesto del Progetto AI Engineer

## Profilo allievo
- Senior developer con 25 anni di esperienza professionale
- Stack principale: SQL Server + C#/.NET + Next.js/TypeScript
- Vuole diventare AI Engineer per lavorare, non per scrivere paper
- Approccio pragmatico: applica subito, teoria solo il minimo per capire cosa si usa
- Ha materiale dal Master Boolean AI Engineering (giudicato troppo accademico — usato come rinforzo)

## Regole operative del corso
- **I progetti sono il veicolo, non la destinazione**: l'obiettivo è l'autonomia, non completare i 3 progetti
- **Pattern-first**: ogni lezione insegna un pattern riusabile, applicato a un progetto reale
- **Ogni lezione include un esercizio su scenario diverso** per fissare il pattern al di fuori del progetto
- **Teoria solo il minimo**: spiegata in 2-3 righe quando serve per una decisione pratica
- **Tagliare senza pietà** tutto ciò che non ha impatto operativo diretto
- **Checkpoint di autonomia**: alla fine di ogni lezione, l'allievo deve saper rispondere "se mi chiedessero la stessa cosa per un dominio diverso, da dove parto?"

## Progetti reali (vedi PROGETTI.md per dettagli)
- **P1**: Import stock prices multi-fornitore (auto-mapping + comparazione)
- **P2**: Anagrafica unica pneumatici (auto-mapping + normalizzazione)
- **P3**: Assistente AI vendita cerchi in lega (RAG + chatbot + email)

## Struttura del corso (v3 — 21 lezioni, 5 moduli)
- Modulo 0: Setup Operativo (lezioni 01-02)
- Modulo 1: AI per Dati Eterogenei — P1, P2 (lezioni 03-09)
- Modulo 2: RAG e Assistente AI — P3 (lezioni 10-15)
- Modulo 3: Nel Tuo Stack (lezioni 16-18)
- Modulo 4: Produzione (lezioni 19-21)

## File nella cartella del progetto
- `PERCORSO.md` — Curriculum completo
- `PROGRESSO.md` — Tracker stato + diario di bordo
- `PROGETTI.md` — Specifiche dei 3 progetti reali
- `CONTESTO.md` — Questo file
- `LEZIONE-XX.md` — Contenuto di ogni lezione

## Istruzioni per Claude
Quando l'utente dice "progetto ai-engineer" (o varianti):
1. Leggere `PROGRESSO.md` per sapere a che lezione siamo
2. Leggere `PROGETTI.md` se serve contesto sui progetti reali
3. Se la lezione corrente esiste, continuare da lì
4. Se non esiste come file, crearla
5. Aggiornare `PROGRESSO.md` quando una lezione viene completata
6. Non salvare mai informazioni di questo progetto nella memoria di sistema
