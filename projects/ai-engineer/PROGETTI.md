# Progetti Reali — Specifiche Operative

> Questi 3 progetti sono il focus del corso. Ogni lezione insegna qualcosa che serve direttamente qui.
> Stesso cliente, dominio: e-commerce automotive (cerchi in lega, pneumatici, ricambi).

---

## Progetto 1 — Import Stock Prices Multi-Fornitore

### Problema
Il cliente riceve listini prezzi/stock da **fornitori diversi**, ognuno con il proprio formato (CSV, Excel, XML, layout proprietari). Oggi l'import è manuale o semi-automatico con mapping hardcoded per ogni fornitore. Ogni nuovo fornitore richiede sviluppo custom.

### Obiettivo
Sistema di importazione **AI-driven** che:
1. **Riceve un file** da un fornitore qualsiasi (struttura sconosciuta)
2. **L'AI analizza** la struttura e mappa automaticamente le colonne allo schema target
3. **Applica regole di esclusione** istruite via prompt (es. "escludi prodotti fuori categoria", "ignora righe senza EAN")
4. **Persiste sul DB** (SQL Server)
5. **Confronta a parità di EAN** i prezzi tra fornitori diversi con algoritmi parametrizzati:
   - Prezzo
   - Nazione di provenienza
   - Tempi di consegna
   - Disponibilità
   - (altri parametri configurabili)
6. **Sceglie il fornitore più conveniente** per ogni prodotto

### Competenze AI coinvolte
- LLM per analisi struttura file e auto-mapping
- Output strutturato (JSON tipizzato)
- Prompt engineering per regole di business
- Pipeline dati AI → SQL Server
- Gestione costi (molti file = molte chiamate)

### Stack previsto
- C# backend (o Python per il modulo AI)
- SQL Server per persistenza
- OpenAI/Claude API per il mapping

---

## Progetto 2 — Anagrafica Unica Pneumatici

### Problema
I produttori di pneumatici inviano ciascuno i propri file catalogo con formati eterogenei. Oggi non esiste un'anagrafica unificata: ogni produttore ha il suo tracciato, i suoi codici, le sue convenzioni di naming.

### Obiettivo
Sistema che:
1. **Riceve file da produttori diversi** (formati eterogenei)
2. **L'AI auto-mappa** le colonne allo schema unificato della tabella target
3. **Normalizza i dati** (naming, unità di misura, formati)
4. **Gestisce duplicati e aggiornamenti** (stesso pneumatico da fonti diverse)
5. **Inserisce/aggiorna** su tabella SQL Server

### Competenze AI coinvolte
- Stesse del Progetto 1 (auto-mapping, structured output, pipeline)
- Normalizzazione e deduplicazione AI-assisted
- Prompt per regole di normalizzazione specifiche del dominio pneumatici

### Stack previsto
- C# backend (o Python per il modulo AI)
- SQL Server

### Note
I Progetti 1 e 2 condividono il cuore tecnico (file eterogenei → AI mapping → DB). Le lezioni del Modulo 1 coprono entrambi. La differenza è nel dominio e nelle regole di business.

---

## Progetto 3 — Assistente AI Vendita (Cerchi in Lega)

### Problema
Il cliente ha dati di **associazione veicoli ↔ cerchi in lega** (quali cerchi sono compatibili con quali veicoli). Oggi le richieste dei clienti (via email e chat sui siti) vengono gestite manualmente. I clienti chiedono cose come:
- "Ho una Golf 7, quali cerchi posso montare?"
- "Questo cerchio va bene sulla mia BMW Serie 3 2019?"
- "Vorrei cerchi da 19 pollici per Audi A4, cosa avete?"

### Obiettivo
Sistema AI che:
1. **Indicizza** i dati di associazione veicoli/cerchi (+ prezzi, disponibilità)
2. **Risponde alle domande** dei clienti basandosi sui dati reali (RAG)
3. **Guida l'acquisto**: suggerisce cerchi compatibili, confronta opzioni, propone alternative
4. **Gestisce email**: legge le email in arrivo e prepara/invia risposte
5. **Chatbot sul sito**: integrazione frontend per chat real-time

### Competenze AI coinvolte
- Embedding e vector database (indicizzazione catalogo)
- RAG (retrieval-augmented generation sui dati reali)
- Function calling (cercare compatibilità, controllare stock, calcolare prezzi)
- Conversazione multi-turno con memoria
- Integrazione email
- Integrazione frontend (chatbot)

### Stack previsto
- Next.js frontend (chatbot con Vercel AI SDK)
- C# backend / API
- SQL Server (dati associazione, stock, prezzi)
- Vector DB (Qdrant o similare) per ricerca semantica
- Claude/OpenAI per generazione risposte

---

## Mappa Progetti → Moduli del Corso

```
MODULO 0 (Setup)
  └─> MODULO 1 (AI per dati eterogenei) ──> Progetto 1 + Progetto 2
  └─> MODULO 2 (RAG + Agenti) ────────────> Progetto 3
  └─> MODULO 3 (Nel tuo stack) ───────────> Tutti e 3
  └─> MODULO 4 (Produzione) ──────────────> Tutti e 3
```
