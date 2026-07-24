# Percorso AI Engineer — Curriculum Operativo v3

> **Allievo**: Senior Developer (25 anni exp. — SQL Server, C#/.NET, Next.js/TypeScript)
> **Professore**: Claude
> **Obiettivo**: Diventare AI Engineer autonomo — i 3 progetti sono il veicolo, non la destinazione
> **Metodo**: Ogni lezione insegna un pattern riusabile, applicato a un progetto reale
> **Progetti**: Vedi `PROGETTI.md`

---

## I 3 progetti in breve

| # | Progetto | Core AI |
|---|----------|---------|
| **P1** | Import stock prices multi-fornitore | LLM auto-mapping + structured output + comparazione |
| **P2** | Anagrafica unica pneumatici | LLM auto-mapping + normalizzazione + dedup |
| **P3** | Assistente AI vendita cerchi in lega | RAG + function calling + chatbot + email |

P1 e P2 condividono il cuore tecnico (file eterogenei → AI → DB). P3 è un sistema diverso (RAG + agente).

---

## MODULO 0 — Setup Operativo
> *Da zero a "chiamo un LLM e ottengo JSON" in 2 lezioni*

| # | Lezione | Cosa produci | Serve a |
|---|---------|-------------|---------|
| 01 | **Ambiente + prima chiamata LLM** | Script che chiama Claude/OpenAI e ottiene una risposta | Tutti |
| 02 | **Output strutturato: Pydantic + JSON** | LLM che restituisce JSON tipizzato e validato | P1, P2 |

---

## MODULO 1 — AI per Dati Eterogenei
> *Il cuore di P1 e P2: file sconosciuti → mapping automatico → DB*

| # | Lezione | Cosa produci | Serve a |
|---|---------|-------------|---------|
| 03 | **Analisi file eterogenei con LLM** | Script che prende un file qualsiasi e ne descrive la struttura | P1, P2 |
| 04 | **Auto-mapping: da file a schema DB** | LLM che mappa colonne sconosciute allo schema target | P1, P2 |
| 05 | **Regole di business via prompt** | Esclusioni, filtri, normalizzazioni istruiti via system prompt | P1, P2 |
| 06 | **Pipeline completa: file → AI → SQL Server** | Pipeline end-to-end: legge file, mappa, valida, persiste | P1, P2 |
| 07 | **Comparazione multi-fornitore** | Matching per EAN, algoritmo parametrico, scelta fornitore ottimale | P1 |
| 08 | **PROGETTO P1: Import stock prices** | Sistema completo funzionante | P1 |
| 09 | **PROGETTO P2: Anagrafica pneumatici** | Sistema completo funzionante | P2 |

---

## MODULO 2 — RAG e Assistente AI
> *Il cuore di P3: dati veicoli/cerchi → chatbot che guida l'acquisto*

| # | Lezione | Cosa produci | Serve a |
|---|---------|-------------|---------|
| 10 | **Embedding + Vector DB** | Catalogo veicoli/cerchi indicizzato, ricerca semantica funzionante | P3 |
| 11 | **RAG: chatbot sui dati reali** | Chatbot che risponde basandosi sui dati di compatibilità | P3 |
| 12 | **Function calling e tool use** | Agente che cerca compatibilità, controlla stock, calcola prezzi | P3 |
| 13 | **Conversazioni e memoria** | Multi-turno, contesto, follow-up, gestione sessioni | P3 |
| 14 | **Integrazione email** | Sistema che legge email, prepara risposte, gestisce thread | P3 |
| 15 | **PROGETTO P3: Assistente vendita AI** | Sistema completo: chatbot + email responder | P3 |

---

## MODULO 3 — Nel Tuo Stack
> *Integrare AI nei tuoi progetti C#, Next.js, SQL Server*

| # | Lezione | Cosa produci | Serve a |
|---|---------|-------------|---------|
| 16 | **Semantic Kernel: AI in C#/.NET** | Pipeline AI nativa in C# per P1/P2 | P1, P2 |
| 17 | **Vercel AI SDK: chatbot in Next.js** | Chatbot streaming React per P3 | P3 |
| 18 | **Claude API in profondità** | Tool use, extended thinking, streaming — pattern avanzati | Tutti |

---

## MODULO 4 — Produzione
> *Portare i 3 progetti in produzione*

| # | Lezione | Cosa produci | Serve a |
|---|---------|-------------|---------|
| 19 | **Costi e scelta modello** | Tabella costi, ottimizzazione batch, caching, routing modelli | Tutti |
| 20 | **Security e prompt injection** | Validazione input, guardrails, difese | P3 |
| 21 | **Deploy, monitoring, MCP** | API deployata, tracing, MCP per estendere i tool | Tutti |

---

## Progressione concreta

```
Lezione 01-02: Setup
    "So chiamare un LLM e ottenere JSON tipizzato"

Lezione 03-06: Competenze base per dati eterogenei
    "So prendere un file sconosciuto, mapparlo e scriverlo su SQL Server"

Lezione 07-09: Progetti P1 e P2 COMPLETI
    "Ho un sistema di import stock prices e un'anagrafica pneumatici funzionanti"

Lezione 10-13: Competenze base per assistente AI
    "So costruire un chatbot RAG con function calling e memoria"

Lezione 14-15: Progetto P3 COMPLETO
    "Ho un assistente vendita che risponde a email e chat"

Lezione 16-18: Integrazione nel mio stack
    "So fare tutto questo in C# e Next.js, non solo in Python"

Lezione 19-21: Produzione
    "I 3 progetti sono pronti per andare live"
```

---

## Materiale Boolean: dove si colloca

| Sessione Boolean | Coperta da | Uso |
|---|---|---|
| Session 1 — LLM data extraction | Lezioni 03-06 | Esercizio di rinforzo su estrazione dati |
| Session 2 — Embeddings + RAG | Lezioni 10-11 | Esempio parallelo per capire il pattern |
| Session 3 — Function calling | Lezione 12 | Esempio di function calling base |

---

## Risorse esterne

### Documentazione operativa
- [Anthropic Docs](https://docs.anthropic.com/) — Claude API, tool use, MCP
- [OpenAI Docs](https://platform.openai.com/docs/) — API, structured output, function calling
- [Qdrant Docs](https://qdrant.tech/documentation/) — Vector database
- [Semantic Kernel](https://learn.microsoft.com/en-us/semantic-kernel/) — AI per .NET
- [Vercel AI SDK](https://sdk.vercel.ai/) — AI per Next.js
- [MCP Specification](https://modelcontextprotocol.io/) — Model Context Protocol

### Libro
- *"AI Engineering"* — Chip Huyen (O'Reilly, 2025)

---

## Come funziona ogni lezione

Ogni lezione ha 5 sezioni:

### 1. Il problema
Cosa devi risolvere nel progetto. Non "cosa imparerai" — cosa devi fare.

### 2. Il pattern
Il concetto generalizzabile che stai imparando, spiegato in modo che lo riconosci la prossima volta che lo incontri:
- **Cos'è** (2-3 righe, non di più)
- **Quando si usa** (quali problemi risolve)
- **Quando NON si usa** (errori comuni, alternative)
- **Ponte dal tuo stack** (a cosa corrisponde in C#/SQL/Next.js)

Questa è la parte che ti rende autonomo. Il progetto passa, il pattern resta.

### 3. Come si fa
Codice funzionante, applicato al progetto specifico. Commentato dove serve.

### 4. Esercizio: applicalo altrove
Un secondo scenario diverso dal progetto, per fissare il pattern. Breve — 15-20 minuti.
Esempi: "ora fai la stessa cosa ma con un CSV di fatture", "ora costruisci un RAG su una knowledge base diversa".

### 5. Checkpoint
Come sapere se hai capito. Non quiz teorici — test pratici:
- "Sai spiegare in 1 frase quando useresti questo pattern?"
- "Se cambio il formato del file, sai dove mettere le mani?"
- "Se il cliente ti chiede la stessa cosa per un altro dominio, sai da dove partire?"

---

## Mappa dei pattern (cosa sai fare dopo il corso)

Questa è la vera misura del risultato — non i 3 progetti, ma i pattern che padroneggi:

| Pattern | Impari in | Riusi quando... |
|---|---|---|
| **LLM come parser** | Lez. 02-03 | Hai dati non strutturati da trasformare in strutturati |
| **Structured output** | Lez. 02 | L'LLM deve restituire dati tipizzati, non testo libero |
| **Auto-mapping AI** | Lez. 04 | Hai fonti dati con schemi sconosciuti o variabili |
| **Business rules via prompt** | Lez. 05 | Regole che cambiano spesso o sono troppo complesse per if/else |
| **Pipeline AI → DB** | Lez. 06 | Qualsiasi flusso: dati in ingresso → AI → persistenza |
| **Comparazione parametrica** | Lez. 07 | Scegliere tra opzioni con criteri pesati e configurabili |
| **Embedding + ricerca semantica** | Lez. 10 | Cercare per significato, non per keyword |
| **RAG** | Lez. 11 | LLM che deve rispondere basandosi su dati specifici |
| **Function calling** | Lez. 12 | LLM che deve fare azioni, non solo rispondere |
| **Conversational memory** | Lez. 13 | Chatbot multi-turno che ricorda il contesto |
| **AI + email** | Lez. 14 | Automatizzare lettura/risposta email con AI |
| **AI in C# (Semantic Kernel)** | Lez. 16 | Integrare AI in qualsiasi progetto .NET |
| **AI in Next.js (Vercel AI SDK)** | Lez. 17 | Chatbot/AI in qualsiasi frontend React |
| **Claude API avanzata** | Lez. 18 | Tool use, thinking, streaming in qualsiasi contesto |
| **Cost optimization** | Lez. 19 | Qualsiasi sistema AI in produzione |
| **Security AI** | Lez. 20 | Qualsiasi sistema AI esposto a utenti |
| **MCP** | Lez. 21 | Estendere un client AI con tool custom |
