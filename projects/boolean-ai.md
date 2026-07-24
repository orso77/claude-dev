# BOOLEAN-AI — Guida pratica ad AI Embeddings, Vector DB e infrastruttura

> Documento pensato per sviluppatori senior che conoscono bene il software engineering
> ma partono da zero sul mondo AI/ML. Niente hype, solo meccanica e pratica.

---

## Indice

1. [Il problema di partenza: perché servono gli embeddings](#1-il-problema-di-partenza)
2. [Cos'è un embedding](#2-cosè-un-embedding)
3. [Come funziona la vettorializzazione dei dati](#3-come-funziona-la-vettorializzazione-dei-dati)
4. [Modelli di embedding: quali esistono e come sceglierli](#4-modelli-di-embedding)
5. [Similarità tra vettori: come si "cerca" nello spazio vettoriale](#5-similarità-tra-vettori)
6. [Vector Database: cos'è e perché non basta un DB tradizionale](#6-vector-database)
7. [Qdrant: architettura, concetti e API](#7-qdrant)
8. [Docker Compose: setup locale per Qdrant](#8-docker-compose-setup-qdrant)
9. [Pipeline pratica end-to-end](#9-pipeline-pratica-end-to-end)
10. [RAG — Retrieval Augmented Generation](#10-rag--retrieval-augmented-generation)
11. [Chunking: come spezzare i dati prima di vettorializzarli](#11-chunking)
12. [Hugging Face: il GitHub dell'AI](#12-hugging-face)
13. [Kaggle: dati, competizioni e notebook](#13-kaggle)
14. [Costi, limiti e trappole comuni](#14-costi-limiti-e-trappole-comuni)
15. [Alternative a Qdrant e confronto Vector DB](#15-alternative-a-qdrant)
16. [Glossario](#16-glossario)
17. [Risorse e prossimi passi](#17-risorse-e-prossimi-passi)

---

## 1. Il problema di partenza

Hai un database SQL Server con milioni di righe. Sai fare `WHERE`, `JOIN`, `LIKE`, full-text search.
Ma queste ricerche sono **lessicali**: trovano corrispondenze esatte o pattern di testo.

Esempio pratico:
- Cerchi `"problema con la stampante"` ma il tuo dato dice `"la printer non funziona"`.
- SQL: zero risultati (le parole non corrispondono).
- Ricerca semantica via embedding: match, perché il **significato** è lo stesso.

Gli embeddings permettono di cercare per **significato**, non per stringa.

Questo è il fondamento di:
- **Ricerca semantica** su documenti, ticket, knowledge base
- **RAG** (dare contesto a un LLM come Claude dai tuoi dati privati)
- **Recommendation systems** (prodotti simili, documenti correlati)
- **Deduplicazione intelligente** (record che dicono la stessa cosa in modi diversi)
- **Classificazione** senza regole manuali

---

## 2. Cos'è un embedding

Un embedding è una **rappresentazione numerica** di un pezzo di informazione (testo, immagine, audio)
sotto forma di **vettore** — cioè un array di numeri decimali (float).

```
Input:  "Il gatto dorme sul divano"
Output: [0.0231, -0.0142, 0.0892, ..., -0.0034]   // es. 1536 float
```

### Proprietà fondamentale

Testi con significato simile producono vettori **vicini** nello spazio multidimensionale.

```
"Il gatto dorme sul divano"     → vettore A
"Il micio riposa sulla poltrona" → vettore B   (vicino ad A)
"La Borsa ha chiuso in rialzo"  → vettore C   (lontano da A e B)
```

### Analogia per sviluppatori

Pensa a un hash, ma invece di produrre un ID univoco, produce una **posizione nello spazio**
dove punti vicini = significati vicini.

- Un hash SHA256 di due stringhe simili produce valori completamente diversi.
- Un embedding di due stringhe simili produce vettori quasi uguali.

### Dimensionalità

Un vettore embedding ha tipicamente **da 384 a 3072 dimensioni** (float32).

| Modello | Dimensioni | Note |
|---------|-----------|------|
| OpenAI `text-embedding-3-small` | 1536 | Buon rapporto qualità/costo |
| OpenAI `text-embedding-3-large` | 3072 | Massima qualità OpenAI |
| Cohere `embed-v4.0` | 1024 | Multilingua forte |
| Open source `all-MiniLM-L6-v2` | 384 | Gratuito, leggero, gira in locale |
| Open source `BGE-large` | 1024 | Gratuito, qualità alta |
| Voyage AI `voyage-3` | 1024 | Ottimo per codice e documenti tecnici |

Più dimensioni = più sfumature di significato catturate, ma anche più spazio e più lento da cercare.

---

## 3. Come funziona la vettorializzazione dei dati

### Il flusso

```
Dato grezzo (testo, immagine, ...)
    │
    ▼
Preprocessing (pulizia, chunking)
    │
    ▼
Modello di embedding (API o locale)
    │
    ▼
Vettore (array di float)
    │
    ▼
Salvataggio in Vector DB (con metadata)
```

### Cosa succede dentro il modello

Non devi sapere la matematica (transformer, attention, ecc.) per usarli.
Quello che conta come sviluppatore:

1. **Input**: una stringa di testo (o batch di stringhe)
2. **Output**: un array di float della dimensione fissa del modello
3. **Determinismo**: stesso input → stesso output (a parità di modello e versione)
4. **Limiti di input**: ogni modello ha un **token limit** (es. 8192 token ≈ 6000 parole per i modelli OpenAI)
5. **Il modello non si aggiorna**: è un modello pre-addestrato. Non "impara" dai tuoi dati.

### Esempio concreto con API OpenAI

```typescript
import OpenAI from "openai";

const openai = new OpenAI({ apiKey: process.env.OPENAI_API_KEY });

const response = await openai.embeddings.create({
  model: "text-embedding-3-small",
  input: "Il gatto dorme sul divano",
});

const vector: number[] = response.data[0].embedding;
// vector.length === 1536
```

### Esempio con modello locale (gratuito, senza API key)

```python
from sentence_transformers import SentenceTransformer

model = SentenceTransformer("all-MiniLM-L6-v2")
vector = model.encode("Il gatto dorme sul divano")
# vector.shape == (384,)
```

### Cosa si può vettorializzare

| Tipo dato | Come |
|-----------|------|
| Testo breve (frasi, titoli) | Direttamente come stringa |
| Testo lungo (documenti, pagine) | Spezzato in **chunk** (vedi sezione Chunking) |
| Righe di un database | Concatenando i campi rilevanti in una stringa |
| Codice sorgente | Come testo (modelli specializzati funzionano meglio) |
| Immagini | Con modelli multimodali (CLIP, ecc.) |
| Audio | Trascrizione → embedding testo, oppure modelli audio dedicati |

---

## 4. Modelli di embedding

### Cloud (API a pagamento)

| Provider | Modello | Dim. | Token limit | Costo indicativo |
|----------|---------|------|-------------|-------------------|
| OpenAI | `text-embedding-3-small` | 1536 | 8191 | ~$0.02 / 1M token |
| OpenAI | `text-embedding-3-large` | 3072 | 8191 | ~$0.13 / 1M token |
| Cohere | `embed-v4.0` | 1024 | 512 | ~$0.10 / 1M token |
| Voyage AI | `voyage-3` | 1024 | 32000 | ~$0.06 / 1M token |
| Google | `text-embedding-004` | 768 | 2048 | Gratuito fino a quota |

### Open source (gratis, girano in locale)

| Modello | Dim. | Qualità | Note |
|---------|------|---------|------|
| `all-MiniLM-L6-v2` | 384 | Buona | Leggero, veloce, ideale per test |
| `BGE-large-en-v1.5` | 1024 | Alta | Uno dei migliori open source |
| `nomic-embed-text-v1.5` | 768 | Alta | Buon bilanciamento |
| `mxbai-embed-large-v1` | 1024 | Alta | Ottimo per multilingua |

### Come scegliere

- **Per iniziare/test**: `all-MiniLM-L6-v2` (locale, gratis, veloce)
- **Per produzione con budget**: OpenAI `text-embedding-3-small` (economico, buona qualità)
- **Per massima qualità**: OpenAI `text-embedding-3-large` o `BGE-large` (locale)
- **Per multilingua**: Cohere `embed-v4.0` o `mxbai-embed-large`

### Regola critica

**Non puoi mescolare vettori generati da modelli diversi.**
Se indicizzi con il modello A, devi cercare con il modello A.
Cambiare modello = ri-vettorializzare tutto.

---

## 5. Similarità tra vettori

Quando cerchi, il vector DB confronta il vettore della tua query con tutti i vettori salvati.

### Metriche di distanza

| Metrica | Formula intuitiva | Quando usarla |
|---------|-------------------|---------------|
| **Cosine similarity** | Angolo tra i due vettori | Default per testo. Ignora la "lunghezza", guarda solo la direzione |
| **Dot product** | Prodotto scalare | Quando i vettori sono già normalizzati (equivale a cosine) |
| **Euclidean (L2)** | Distanza geometrica nello spazio | Meno comune per testo, più per immagini |

### Cosine similarity spiegata

```
Cosine similarity = 1.0  → identici
Cosine similarity = 0.0  → completamente scorrelati
Cosine similarity = -1.0 → opposti
```

In pratica, per embedding testuali:
- `> 0.85` → molto simili
- `0.70 - 0.85` → correlati
- `< 0.50` → poco o nulla a che fare

(Le soglie variano per modello — vanno calibrate sui tuoi dati.)

### Come funziona la ricerca

```
1. L'utente scrive: "problema stampante"
2. Il testo viene vettorializzato → query_vector
3. Il vector DB cerca i K vettori più vicini a query_vector (KNN)
4. Restituisce i risultati ordinati per similarità, con score e metadata
```

### Approximate Nearest Neighbor (ANN)

Con milioni di vettori, confrontare tutti uno per uno è troppo lento.
I vector DB usano algoritmi **approssimati** (ANN) che sono ~100x più veloci
sacrificando una piccola percentuale di accuratezza (tipicamente 95-99% recall).

Algoritmi principali:
- **HNSW** (Hierarchical Navigable Small World) — il più usato, ottimo bilanciamento velocità/accuratezza
- **IVF** (Inverted File Index) — più efficiente in memoria per dataset enormi
- **PQ** (Product Quantization) — compressione dei vettori, meno memoria ma meno preciso

Qdrant usa **HNSW** di default.

---

## 6. Vector Database

### Perché non basta PostgreSQL con pgvector?

Puoi effettivamente usare PostgreSQL + estensione `pgvector`. Per piccoli dataset (< 1M vettori)
funziona. Ma:

| Aspetto | pgvector | Vector DB dedicato (Qdrant, ecc.) |
|---------|----------|-----------------------------------|
| Performance > 1M vettori | Degrada | Ottimizzato |
| Indici ANN | Solo HNSW e IVF-flat | HNSW + quantizzazione avanzata |
| Filtering + vector search | Sequenziale (filtra poi cerca o viceversa) | Integrato (filtra DURANTE la ricerca) |
| Sharding / distribuzione | Manuale | Built-in |
| Aggiornamento real-time | Lock-based | Ottimizzato per write concorrenti |
| Gestione memoria | Generico | Ottimizzato per vettori (mmap, quantization) |

### Cosa fa un Vector DB

1. **Salva** vettori con metadata associati (payload)
2. **Indicizza** i vettori per ricerca veloce (HNSW, ecc.)
3. **Cerca** i K vettori più simili a un vettore query (KNN / ANN)
4. **Filtra** per metadata durante la ricerca
5. **Scala** su milioni/miliardi di vettori

### Concetti chiave (comuni a tutti i vector DB)

| Concetto | Equivalente SQL | Descrizione |
|----------|----------------|-------------|
| **Collection** | Tabella | Contenitore di vettori con stessa dimensionalità |
| **Point** | Riga | Un vettore + il suo payload (metadata) |
| **Vector** | — | L'array di float |
| **Payload** | Colonne aggiuntive | JSON con metadata associati al vettore |
| **Index** | Indice | Struttura HNSW per ricerca veloce |

---

## 7. Qdrant

### Perché Qdrant

- **Open source** (Apache 2.0)
- Scritto in **Rust** (performance, affidabilità)
- API REST e gRPC
- **Filtering avanzato** durante la ricerca (non dopo)
- Client ufficiali: Python, TypeScript/JS, Rust, Go, Java, C#
- Gira perfettamente in Docker
- Versione cloud disponibile (Qdrant Cloud) per produzione

### Architettura Qdrant

```
┌──────────────────────────────────┐
│           Qdrant Server          │
│                                  │
│  ┌──────────┐  ┌──────────────┐  │
│  │Collection│  │  Collection  │  │
│  │ "docs"   │  │  "products"  │  │
│  │          │  │              │  │
│  │ Points:  │  │  Points:     │  │
│  │  - vector│  │   - vector   │  │
│  │  - payload│ │   - payload  │  │
│  │  - id    │  │   - id       │  │
│  └──────────┘  └──────────────┘  │
│                                  │
│  Storage: disk (mmap) o memory   │
│  Index: HNSW per collection      │
└──────────────────────────────────┘
```

### API principali (REST)

**Creare una collection:**
```http
PUT /collections/my_docs
{
  "vectors": {
    "size": 1536,
    "distance": "Cosine"
  }
}
```

**Inserire punti (upsert):**
```http
PUT /collections/my_docs/points
{
  "points": [
    {
      "id": 1,
      "vector": [0.0231, -0.0142, ...],
      "payload": {
        "title": "Guida installazione",
        "category": "docs",
        "created_at": "2025-01-15"
      }
    }
  ]
}
```

**Cercare (KNN con filtro):**
```http
POST /collections/my_docs/points/query
{
  "query": [0.0451, -0.0089, ...],
  "filter": {
    "must": [
      { "key": "category", "match": { "value": "docs" } }
    ]
  },
  "limit": 5,
  "with_payload": true
}
```

### Client TypeScript

```typescript
import { QdrantClient } from "@qdrant/js-client-rest";

const client = new QdrantClient({ host: "localhost", port: 6333 });

// Creare collection
await client.createCollection("my_docs", {
  vectors: { size: 1536, distance: "Cosine" },
});

// Inserire
await client.upsert("my_docs", {
  points: [
    {
      id: 1,
      vector: embeddingVector,
      payload: { title: "Guida installazione", category: "docs" },
    },
  ],
});

// Cercare
const results = await client.query("my_docs", {
  query: queryVector,
  filter: {
    must: [{ key: "category", match: { value: "docs" } }],
  },
  limit: 5,
  with_payload: true,
});
```

### Client C#

```csharp
using Qdrant.Client;
using Qdrant.Client.Grpc;

var client = new QdrantClient("localhost", 6334); // gRPC port

// Creare collection
await client.CreateCollectionAsync("my_docs", new VectorParams
{
    Size = 1536,
    Distance = Distance.Cosine
});

// Inserire
await client.UpsertAsync("my_docs", [
    new PointStruct
    {
        Id = 1,
        Vectors = embeddingVector,
        Payload =
        {
            ["title"] = "Guida installazione",
            ["category"] = "docs"
        }
    }
]);

// Cercare
var results = await client.QueryAsync("my_docs",
    query: queryVector,
    filter: new Filter
    {
        Must =
        {
            new Condition
            {
                Field = new FieldCondition
                {
                    Key = "category",
                    Match = new Match { Keyword = "docs" }
                }
            }
        }
    },
    limit: 5,
    payloadSelector: true
);
```

### Payload filtering

Qdrant supporta filtri ricchi sui payload, simili a `WHERE` in SQL:

| Operatore Qdrant | Equivalente SQL |
|-------------------|----------------|
| `match` (keyword) | `= 'valore'` |
| `match` (integer) | `= 123` |
| `range` (gt, lt, gte, lte) | `> 10 AND < 100` |
| `must` | `AND` |
| `should` | `OR` |
| `must_not` | `NOT` |
| `has_id` | `WHERE id IN (...)` |
| `nested` | Filtro su oggetti annidati |

### Payload index

Come in SQL, se filtri spesso per un campo, crea un indice:

```http
PUT /collections/my_docs/index
{
  "field_name": "category",
  "field_schema": "keyword"
}
```

---

## 8. Docker Compose: setup Qdrant

### File `docker-compose.yml`

```yaml
services:
  qdrant:
    image: qdrant/qdrant:latest
    container_name: qdrant
    ports:
      - "6333:6333"   # REST API
      - "6334:6334"   # gRPC
    volumes:
      - qdrant_data:/qdrant/storage
    environment:
      - QDRANT__SERVICE__GRPC_PORT=6334
    restart: unless-stopped

volumes:
  qdrant_data:
    driver: local
```

### Comandi

```bash
# Avviare
docker compose up -d

# Verificare che sia attivo
curl http://localhost:6333/healthz
# Risposta attesa: "All good"  (HTTP 200)

# Dashboard web (browser)
# http://localhost:6333/dashboard

# Fermare
docker compose down

# Fermare e cancellare i dati
docker compose down -v
```

### Setup con API key (per ambienti esposti)

```yaml
services:
  qdrant:
    image: qdrant/qdrant:latest
    container_name: qdrant
    ports:
      - "6333:6333"
      - "6334:6334"
    volumes:
      - qdrant_data:/qdrant/storage
    environment:
      - QDRANT__SERVICE__API_KEY=la-tua-api-key-segreta
    restart: unless-stopped

volumes:
  qdrant_data:
    driver: local
```

Client con API key:
```typescript
const client = new QdrantClient({
  host: "localhost",
  port: 6333,
  apiKey: "la-tua-api-key-segreta",
});
```

### Docker Compose completo: Qdrant + app di test

```yaml
services:
  qdrant:
    image: qdrant/qdrant:latest
    container_name: qdrant
    ports:
      - "6333:6333"
      - "6334:6334"
    volumes:
      - qdrant_data:/qdrant/storage
    restart: unless-stopped
    healthcheck:
      test: ["CMD-SHELL", "curl -f http://localhost:6333/healthz || exit 1"]
      interval: 10s
      timeout: 5s
      retries: 3

  # Esempio: la tua app .NET che usa Qdrant
  # app:
  #   build: ./src/MyApp
  #   depends_on:
  #     qdrant:
  #       condition: service_healthy
  #   environment:
  #     - QDRANT_HOST=qdrant
  #     - QDRANT_PORT=6334

volumes:
  qdrant_data:
    driver: local
```

---

## 9. Pipeline pratica end-to-end

### Fase 1: Ingestione (indicizzazione)

```
Sorgente dati (DB, file, API)
    │
    ▼
Estrazione testo
    │
    ▼
Preprocessing + Chunking
    │
    ▼
Embedding (modello) ──────────► Vettore
    │                               │
    ▼                               ▼
Metadata (payload)            Vector DB
    │                               │
    └───────────────────────────────┘
              Upsert nel DB
```

### Fase 2: Ricerca (query)

```
Query utente (testo)
    │
    ▼
Embedding (stesso modello!) ──► Query vector
    │
    ▼
Vector DB: ricerca KNN + filtri
    │
    ▼
Risultati ordinati per similarità
    │
    ▼
Post-processing (reranking, soglie, ecc.)
```

### Esempio completo TypeScript

```typescript
import { QdrantClient } from "@qdrant/js-client-rest";
import OpenAI from "openai";

const qdrant = new QdrantClient({ host: "localhost", port: 6333 });
const openai = new OpenAI();

const COLLECTION = "knowledge_base";
const MODEL = "text-embedding-3-small";

// --- HELPER: genera embedding ---
async function embed(text: string): Promise<number[]> {
  const res = await openai.embeddings.create({
    model: MODEL,
    input: text,
  });
  return res.data[0].embedding;
}

// --- SETUP: crea collection ---
async function setup(): Promise<void> {
  await qdrant.createCollection(COLLECTION, {
    vectors: { size: 1536, distance: "Cosine" },
  });
  await qdrant.createPayloadIndex(COLLECTION, {
    field_name: "source",
    field_schema: "keyword",
  });
}

// --- INGESTIONE: indicizza documenti ---
async function ingest(docs: { id: number; text: string; source: string }[]): Promise<void> {
  const points = await Promise.all(
    docs.map(async (doc) => ({
      id: doc.id,
      vector: await embed(doc.text),
      payload: { text: doc.text, source: doc.source },
    }))
  );
  await qdrant.upsert(COLLECTION, { points });
}

// --- RICERCA ---
async function search(query: string, source?: string, limit = 5) {
  const queryVector = await embed(query);

  const filter = source
    ? { must: [{ key: "source", match: { value: source } }] }
    : undefined;

  return qdrant.query(COLLECTION, {
    query: queryVector,
    filter,
    limit,
    with_payload: true,
  });
}

// --- USO ---
await setup();

await ingest([
  { id: 1, text: "Per installare il software, scaricare il pacchetto dal sito.", source: "manual" },
  { id: 2, text: "In caso di errore 503, riavviare il servizio applicativo.", source: "troubleshoot" },
  { id: 3, text: "La stampante va configurata dalla sezione Dispositivi.", source: "manual" },
]);

const results = await search("come risolvere errori del server");
// Risultato atteso: il doc #2 avrà lo score più alto
```

---

## 10. RAG — Retrieval Augmented Generation

### Cos'è

RAG è il pattern per dare a un LLM (Claude, GPT, ecc.) **contesto dai tuoi dati**
senza fare fine-tuning del modello.

```
Domanda utente
    │
    ├──► Ricerca semantica nel Vector DB ──► Documenti rilevanti
    │                                              │
    └──────────────────────────────────────────────┘
                         │
                         ▼
              Prompt = Domanda + Contesto recuperato
                         │
                         ▼
                    LLM (Claude, GPT)
                         │
                         ▼
                   Risposta basata sui tuoi dati
```

### Perché RAG e non fine-tuning?

| Aspetto | RAG | Fine-tuning |
|---------|-----|-------------|
| Costo | Basso (solo embedding + inference) | Alto (training GPU) |
| Aggiornamento dati | Immediato (aggiungi al vector DB) | Richiede re-training |
| Trasparenza | Puoi mostrare le fonti | Black box |
| Allucinazioni | Ridotte (il contesto è reale) | Possibili |
| Setup | Ore | Giorni/settimane |

### Esempio RAG con Claude

```typescript
import Anthropic from "@anthropic-ai/sdk";

const anthropic = new Anthropic();

async function askWithRAG(question: string): Promise<string> {
  // 1. Cerca contesto nel vector DB
  const searchResults = await search(question, undefined, 3);

  // 2. Costruisci il contesto
  const context = searchResults.points
    .map((p) => p.payload?.text)
    .join("\n---\n");

  // 3. Chiedi a Claude con il contesto
  const response = await anthropic.messages.create({
    model: "claude-sonnet-4-6",
    max_tokens: 1024,
    messages: [
      {
        role: "user",
        content: `Rispondi alla domanda basandoti SOLO sul contesto fornito.
Se il contesto non contiene informazioni sufficienti, dillo esplicitamente.

CONTESTO:
${context}

DOMANDA: ${question}`,
      },
    ],
  });

  return response.content[0].type === "text" ? response.content[0].text : "";
}
```

---

## 11. Chunking

### Il problema

I modelli di embedding hanno un **limite di token** (es. 8192 token).
Un documento lungo 50 pagine non ci sta.
Inoltre, un singolo embedding per un documento enorme cattura male i dettagli.

### La soluzione: chunking

Spezzare il documento in pezzi (chunk) più piccoli, ognuno vettorializzato separatamente.

### Strategie di chunking

| Strategia | Come funziona | Pro | Contro |
|-----------|---------------|-----|--------|
| **Fixed size** | Taglia ogni N caratteri/token | Semplice, prevedibile | Spezza frasi a metà |
| **Fixed size + overlap** | N caratteri con sovrapposizione | Riduce perdita di contesto ai bordi | Più chunk, più spazio |
| **Sentence-based** | Spezza per frasi complete | Rispetta la struttura del testo | Chunk di dimensione variabile |
| **Paragraph-based** | Spezza per paragrafi | Unità semantiche naturali | Paragrafi molto lunghi o molto corti |
| **Recursive** | Prova separatori gerarchici (paragrafo → frase → parola) | Bilanciamento buono | Più complesso |
| **Semantic** | Usa embeddings per trovare punti di rottura naturali | Chunk semanticamente coerenti | Lento, costoso |

### Valori di partenza consigliati

- **Dimensione chunk**: 500-1000 token (≈ 375-750 parole)
- **Overlap**: 50-100 token (10-20% del chunk)
- **Minimo chunk**: non sotto 100 token (troppo poco contesto)

### Esempio pratico

```typescript
function chunkText(text: string, maxChars = 1000, overlap = 200): string[] {
  const chunks: string[] = [];
  let start = 0;

  while (start < text.length) {
    let end = start + maxChars;

    // Cerca un punto di interruzione naturale (fine frase)
    if (end < text.length) {
      const lastPeriod = text.lastIndexOf(".", end);
      const lastNewline = text.lastIndexOf("\n", end);
      const breakPoint = Math.max(lastPeriod, lastNewline);

      if (breakPoint > start + maxChars * 0.5) {
        end = breakPoint + 1;
      }
    }

    chunks.push(text.slice(start, end).trim());
    start = end - overlap;
  }

  return chunks;
}
```

### Metadati nei chunk

Ogni chunk dovrebbe portare con sé metadati che permettano di risalire alla sorgente:

```typescript
{
  id: "doc_123_chunk_2",
  vector: [...],
  payload: {
    text: "contenuto del chunk...",
    source_document: "guida_installazione.pdf",
    chunk_index: 2,
    total_chunks: 15,
    page: 3,
    section: "Configurazione iniziale"
  }
}
```

---

## 12. Hugging Face

### Cos'è

Hugging Face (HF) è **il GitHub del mondo AI/ML**. È la piattaforma dove la community open source
pubblica, condivide e usa modelli, dataset e applicazioni AI.

Se GitHub ospita codice sorgente, Hugging Face ospita:
- **Modelli** pre-addestrati (LLM, embedding, classificatori, generazione immagini, ecc.)
- **Dataset** pubblici e privati
- **Spaces** — app web demo che girano direttamente sulla piattaforma
- **Librerie** open source (Transformers, Datasets, Tokenizers, ecc.)

### Perché ti serve

Come sviluppatore che entra nel mondo AI, Hugging Face è il posto dove:
1. **Trovi modelli di embedding** da usare in locale (gratis, senza API key)
2. **Scarichi modelli** con una riga di codice
3. **Confronti modelli** sulle leaderboard pubbliche
4. **Trovi dataset** per testare le tue pipeline
5. **Ospiti le tue app AI** gratuitamente (Spaces)

### Il Hub: la parte centrale

L'Hub è il registry centrale. Ogni risorsa ha un ID nel formato `owner/name`.

```
Modelli:    sentence-transformers/all-MiniLM-L6-v2
Dataset:    squad, wikipedia, imdb
Spaces:     stabilityai/stable-diffusion
```

**URL**: `https://huggingface.co/{owner}/{name}`

### Come navigare i modelli

Vai su https://huggingface.co/models e usa i filtri:

| Filtro | Esempio | Uso |
|--------|---------|-----|
| **Task** | `feature-extraction` | Modelli di embedding |
| **Task** | `text-generation` | LLM (Claude-like) |
| **Task** | `text-classification` | Classificatori |
| **Library** | `sentence-transformers` | Compatibili con la libreria ST |
| **Language** | `it`, `multilingual` | Supporto italiano |
| **Sort by** | `downloads`, `trending` | I più usati / popolari |

#### Modelli di embedding utili per il nostro contesto

| Modello HF | Dim. | Multilingua | Note |
|------------|------|-------------|------|
| `sentence-transformers/all-MiniLM-L6-v2` | 384 | Inglese (ok multilingua) | Perfetto per iniziare |
| `BAAI/bge-large-en-v1.5` | 1024 | Inglese | Top qualità open source |
| `intfloat/multilingual-e5-large` | 1024 | 100+ lingue | Ottimo per italiano |
| `nomic-ai/nomic-embed-text-v1.5` | 768 | Multilingua | Buon bilanciamento |
| `jinaai/jina-embeddings-v3` | 1024 | Multilingua | Molto recente, ottimo |

### La Model Card

Ogni modello ha una **Model Card** (README.md) che contiene:
- Cosa fa il modello
- Come usarlo (codice pronto da copiare)
- Metriche di performance (benchmark)
- Limitazioni e bias
- Licenza

**Leggi sempre la Model Card prima di usare un modello.** È l'equivalente del README di un repo GitHub.

### Usare modelli HF nel tuo codice

#### Python — con `sentence-transformers`

```bash
pip install sentence-transformers
```

```python
from sentence_transformers import SentenceTransformer

# Scarica automaticamente il modello da HF Hub al primo uso
model = SentenceTransformer("sentence-transformers/all-MiniLM-L6-v2")

# Genera embedding
embeddings = model.encode([
    "Il gatto dorme sul divano",
    "La stampante non funziona",
])
# embeddings.shape == (2, 384)
```

Il modello viene scaricato e cachato in `~/.cache/huggingface/`. Le esecuzioni successive sono istantanee.

#### Python — con `transformers` (la libreria core)

```bash
pip install transformers torch
```

```python
from transformers import AutoTokenizer, AutoModel
import torch

model_name = "sentence-transformers/all-MiniLM-L6-v2"
tokenizer = AutoTokenizer.from_pretrained(model_name)
model = AutoModel.from_pretrained(model_name)

inputs = tokenizer("Il gatto dorme sul divano", return_tensors="pt", padding=True, truncation=True)
with torch.no_grad():
    outputs = model(**inputs)

# Mean pooling per ottenere un singolo vettore
embeddings = outputs.last_hidden_state.mean(dim=1)
# embeddings.shape == torch.Size([1, 384])
```

#### TypeScript/Node.js — con `@xenova/transformers` (gira in locale senza Python)

```bash
npm install @xenova/transformers
```

```typescript
import { pipeline } from "@xenova/transformers";

// Scarica e cacha il modello al primo uso
const embedder = await pipeline("feature-extraction", "Xenova/all-MiniLM-L6-v2");

const output = await embedder("Il gatto dorme sul divano", {
  pooling: "mean",
  normalize: true,
});
// output.data è un Float32Array di 384 elementi
```

### Hugging Face Inference API (senza scaricare nulla)

Per test rapidi puoi chiamare i modelli direttamente via API, senza installarli in locale:

```bash
curl https://api-inference.huggingface.co/models/sentence-transformers/all-MiniLM-L6-v2 \
  -H "Authorization: Bearer hf_xxxYOUR_TOKENxxx" \
  -H "Content-Type: application/json" \
  -d '{"inputs": "Il gatto dorme sul divano"}'
```

**Rate limit gratuito**: ~1000 richieste/giorno (varia per modello).
Per volumi più alti: Inference Endpoints (pay-per-use) o self-hosting.

### Token HF e autenticazione

Per accedere a modelli gated (es. Llama, Mistral) o all'Inference API:

1. Crea account su https://huggingface.co
2. Vai su Settings → Access Tokens
3. Crea un token (Read è sufficiente per scaricare modelli)
4. Usalo via env var:

```bash
export HF_TOKEN=hf_xxxYOUR_TOKENxxx
```

oppure login CLI:

```bash
pip install huggingface_hub
huggingface-cli login
```

### Hugging Face Spaces

Spaces sono **app web** che girano sulla piattaforma HF. Puoi:
- **Provare modelli** con un'interfaccia grafica senza installare nulla
- **Pubblicare le tue demo** (Gradio, Streamlit, Docker)
- **Vedere come altri usano** un modello (il codice è visibile)

Esempi utili:
- `mteb/leaderboard` — classifica dei modelli di embedding (MTEB benchmark)
- `sentence-transformers/similarity` — testa la similarità semantica online

### Leaderboard MTEB (come scegliere il modello di embedding giusto)

**MTEB** (Massive Text Embedding Benchmark) è LA classifica di riferimento per i modelli di embedding.

URL: https://huggingface.co/spaces/mteb/leaderboard

| Colonna | Cosa misura |
|---------|-------------|
| **Retrieval** | Qualità nella ricerca semantica (il più rilevante per RAG) |
| **Classification** | Classificazione di testi |
| **Clustering** | Raggruppamento di testi simili |
| **STS** | Semantic Textual Similarity (correlazione con giudizi umani) |
| **Model Size** | Dimensione del modello (più grande = più lento) |

**Consiglio**: ordina per **Retrieval** se il tuo caso d'uso è ricerca/RAG.

### Hugging Face Datasets

Oltre ai modelli, HF ospita **dataset** pronti all'uso:

```python
from datasets import load_dataset

# Scarica il dataset direttamente
dataset = load_dataset("squad")  # Stanford Question Answering Dataset

# Accedi ai dati
for item in dataset["train"]:
    print(item["question"], item["context"])
    break
```

Dataset utili per testare pipeline di embedding/RAG:
- `wikipedia` — dump completo Wikipedia (per test su larga scala)
- `squad` / `squad_it` — domande + contesto + risposte
- `ms_marco` — query di ricerca + documenti rilevanti
- `mteb/*` — dataset di benchmark per embedding

---

## 13. Kaggle

### Cos'è

Kaggle è una piattaforma di Google che offre:
1. **Competizioni** di data science e ML (con premi in denaro)
2. **Dataset** pubblici (uno dei più grandi archivi al mondo)
3. **Notebook** (Jupyter) con GPU/TPU gratuiti
4. **Modelli** pre-addestrati
5. **Corsi gratuiti** su ML, Python, SQL, ecc.

### Perché ti serve (come sviluppatore, non come data scientist)

Anche se non partecipi alle competizioni, Kaggle è prezioso per:
- **Dataset reali** per testare le tue pipeline di embedding/RAG
- **Notebook gratuiti con GPU** per eseguire modelli pesanti senza infrastruttura
- **Esempi pratici** scritti da altri (cerca notebook per tecnologia)
- **Corsi** ben strutturati se vuoi approfondire i fondamenti

### Account e setup

1. Vai su https://www.kaggle.com e crea account (o login con Google)
2. Per usare l'API: vai su Settings → API → "Create New Token"
3. Scarica `kaggle.json` e mettilo in `~/.kaggle/kaggle.json`

```bash
pip install kaggle

# Verifica che funzioni
kaggle datasets list
```

### Dataset: come trovarli e usarli

#### Dalla web UI

1. Vai su https://www.kaggle.com/datasets
2. Cerca per argomento (es. "customer support tickets", "product reviews italian")
3. Filtra per: dimensione, formato (CSV, JSON, Parquet), licenza, popolarità

#### Dalla CLI

```bash
# Cerca dataset
kaggle datasets list -s "customer reviews"

# Scarica un dataset
kaggle datasets download -d snap/amazon-fine-food-reviews
# Scarica un .zip nella directory corrente

# Unzip
unzip amazon-fine-food-reviews.zip -d ./data/
```

#### Da codice Python

```python
import kaggle

# Scarica programmaticamente
kaggle.api.dataset_download_files("snap/amazon-fine-food-reviews", path="./data", unzip=True)
```

### Dataset utili per testare embedding e RAG

| Dataset | Righe | Descrizione | Uso |
|---------|-------|-------------|-----|
| `snap/amazon-fine-food-reviews` | 568K | Recensioni prodotti alimentari | Ricerca semantica su testo breve |
| `Cornell-University/arxiv` | 2M+ | Paper scientifici (titolo + abstract) | RAG su documenti tecnici |
| `yelp-dataset/yelp-dataset` | 6M+ | Recensioni business | Ricerca + classificazione |
| `stackoverflow/stacksample` | 10M+ | Domande + risposte StackOverflow | RAG su knowledge base tecnica |
| `huggingface/wikipedia` | Variabile | Dump Wikipedia | Test larga scala |

### Notebook Kaggle: il tuo ambiente gratuito con GPU

Questa è una delle feature più utili per chi inizia.

**Cosa ottieni gratis:**
- 30 ore/settimana di GPU (NVIDIA T4 o P100)
- 20 ore/settimana di TPU
- 20 GB di disco
- Python pre-installato con tutte le librerie ML principali
- Accesso diretto ai dataset Kaggle (zero download)

#### Come creare un notebook

1. Vai su https://www.kaggle.com/code
2. Click "New Notebook"
3. Scegli "GPU T4 x2" come acceleratore (Settings → Accelerator)
4. Scrivi codice nelle celle, esegui con Shift+Enter

#### Esempio: testare un modello di embedding su Kaggle

```python
# Cella 1: Installa dipendenze
!pip install sentence-transformers qdrant-client -q

# Cella 2: Carica modello e genera embedding
from sentence_transformers import SentenceTransformer
import pandas as pd

model = SentenceTransformer("sentence-transformers/all-MiniLM-L6-v2")

# Usa un dataset Kaggle già montato
df = pd.read_csv("/kaggle/input/amazon-fine-food-reviews/Reviews.csv")
df = df.head(1000)  # Prendi solo 1000 righe per test

# Genera embedding per le review
texts = df["Text"].fillna("").tolist()
embeddings = model.encode(texts, show_progress_bar=True, batch_size=64)

print(f"Generati {len(embeddings)} embedding di dimensione {embeddings[0].shape[0]}")
```

```python
# Cella 3: Ricerca semantica in-memory (senza Qdrant)
import numpy as np

def cosine_similarity(a, b):
    return np.dot(a, b) / (np.linalg.norm(a) * np.linalg.norm(b))

query = "terrible taste, would not buy again"
query_emb = model.encode(query)

# Calcola similarità con tutte le review
scores = [cosine_similarity(query_emb, emb) for emb in embeddings]
top_indices = np.argsort(scores)[-5:][::-1]

for idx in top_indices:
    print(f"Score: {scores[idx]:.4f} | {df.iloc[idx]['Text'][:100]}...")
```

```python
# Cella 4: Con Qdrant in-memory (nessun server Docker necessario)
from qdrant_client import QdrantClient
from qdrant_client.models import VectorParams, Distance, PointStruct

# Qdrant in-memory mode — perfetto per test su Kaggle
client = QdrantClient(":memory:")

client.create_collection(
    "reviews",
    vectors_config=VectorParams(size=384, distance=Distance.COSINE),
)

points = [
    PointStruct(
        id=i,
        vector=embeddings[i].tolist(),
        payload={"text": texts[i][:500], "score": int(df.iloc[i]["Score"])},
    )
    for i in range(len(embeddings))
]
client.upsert("reviews", points)

# Ricerca
results = client.query_points(
    "reviews",
    query=query_emb.tolist(),
    limit=5,
    with_payload=True,
)

for point in results.points:
    print(f"Score: {point.score:.4f} | Rating: {point.payload['score']} | {point.payload['text'][:80]}...")
```

### Kaggle come ambiente di sperimentazione

#### Workflow consigliato per iniziare

```
1. Scegli un dataset Kaggle rilevante per il tuo dominio
2. Crea un notebook Kaggle con GPU
3. Testa diversi modelli di embedding (HF Hub) sullo stesso dataset
4. Misura la qualità della ricerca semantica
5. Una volta trovato il setup giusto, portalo nel tuo progetto locale/Docker
```

#### Trucchi utili nei notebook Kaggle

```python
# Vedere i dataset disponibili nel notebook
import os
print(os.listdir("/kaggle/input"))

# Salvare output (persiste tra sessioni)
df.to_csv("/kaggle/working/results.csv", index=False)

# Scaricare file dal notebook
from IPython.display import FileLink
FileLink("/kaggle/working/results.csv")

# Misurare tempo di esecuzione di una cella
%%time
embeddings = model.encode(texts, batch_size=64)

# Usare tqdm per progress bar
from tqdm import tqdm
for batch in tqdm(batches):
    process(batch)
```

### Competizioni Kaggle (opzionale, ma istruttivo)

Anche se non ti interessa competere, le competizioni passate sono miniere d'oro:

1. Vai su https://www.kaggle.com/competitions (filtra per "completed")
2. Cerca competizioni relative a NLP, search, recommendation
3. Guarda le **soluzioni vincenti** (tab "Discussion" → "Winners' solutions")
4. Studia i notebook pubblici dei primi classificati

Competizioni storiche utili per capire embedding/search:
- **Quora Question Pairs** — trovare domande duplicate (semantic similarity)
- **Google Quest Q&A Labeling** — qualità risposte (ranking)
- **Shopee - Price Match Guarantee** — matching prodotti (multimodale: testo + immagine)
- **Learning Equality - Curriculum Recommendations** — raccomandazione contenuti educativi

### Kaggle vs Hugging Face: quando usare cosa

| Scenario | Usa | Perché |
|----------|-----|--------|
| Cerchi un modello di embedding | Hugging Face | Hub modelli più completo, MTEB leaderboard |
| Cerchi un dataset per testare | Entrambi | Kaggle ha più dataset tabulari, HF più dataset NLP |
| Vuoi eseguire codice con GPU gratis | Kaggle | 30h/settimana di GPU gratuite |
| Vuoi capire come altri hanno risolto un problema | Kaggle | Competizioni + notebook pubblici |
| Vuoi pubblicare/scaricare un modello | Hugging Face | Standard de facto per distribuzione modelli |
| Vuoi una demo web del tuo modello | Hugging Face | Spaces (Gradio/Streamlit hosting gratuito) |

---

## 14. Costi, limiti e trappole comuni

### Costi

| Voce | Ordine di grandezza |
|------|---------------------|
| Embedding 1M documenti brevi (OpenAI small) | ~$2-5 |
| Embedding 1M documenti brevi (locale) | $0 (solo CPU/GPU) |
| Qdrant self-hosted (Docker) | $0 (solo infrastruttura) |
| Qdrant Cloud (1M vettori, 1536 dim) | ~$25-50/mese |
| Storage: 1M vettori × 1536 dim × 4 byte | ~6 GB raw + indice |

### Trappole comuni

**1. Mescolare modelli di embedding**
Indicizzi con il modello A, cerchi con il modello B → risultati insensati.
I vettori non sono compatibili tra modelli diversi.

**2. Non fare chunking (o farlo male)**
Documento intero come singolo embedding → perde dettagli.
Chunk troppo piccoli → perde contesto.

**3. Ignorare i metadata/filtri**
Cercare su tutto il dataset quando potresti filtrare per categoria, data, tipo.
I filtri riducono lo spazio di ricerca e migliorano la qualità.

**4. Non testare con dati reali**
Gli embedding funzionano diversamente per lingua, dominio, lunghezza testo.
Testa sempre con i tuoi dati reali, non con esempi giocattolo.

**5. Aspettarsi precisione SQL**
La ricerca vettoriale è **probabilistica**. Non restituisce "la riga esatta" ma
"i risultati più simili". Serve quasi sempre un passo di post-processing o reranking.

**6. Non gestire gli aggiornamenti**
Se il dato sorgente cambia, il vettore va ri-generato e aggiornato nel vector DB.
Servono pipeline di sync (batch o event-driven).

**7. Embedding di campi sbagliati**
Vettorializzare l'ID o il timestamp non ha senso semantico.
Scegli i campi che contengono **significato** (descrizioni, titoli, contenuto).

---

## 15. Alternative a Qdrant

| Vector DB | Licenza | Linguaggio | Hosting | Note |
|-----------|---------|-----------|---------|------|
| **Qdrant** | Apache 2.0 | Rust | Self-hosted / Cloud | Filtering forte, performance |
| **Weaviate** | BSD-3 | Go | Self-hosted / Cloud | Schema-first, moduli integrati |
| **Milvus** | Apache 2.0 | Go/C++ | Self-hosted / Zilliz Cloud | Scalabilità enterprise |
| **Pinecone** | Proprietary | — | Solo cloud | Serverless, zero ops |
| **ChromaDB** | Apache 2.0 | Python | Self-hosted | Semplicissimo, ottimo per prototipi |
| **pgvector** | PostgreSQL | C | Nel tuo PostgreSQL | Zero infra aggiuntiva se hai già PG |
| **Redis Stack** | SSPL | C | Self-hosted / Cloud | Se hai già Redis |

### Scelta rapida

- **Prototipo locale veloce**: ChromaDB o pgvector
- **Produzione self-hosted**: Qdrant o Milvus
- **Produzione zero-ops**: Pinecone o Qdrant Cloud
- **Già hai PostgreSQL**: pgvector (se < 1M vettori)

---

## 16. Glossario

| Termine | Significato |
|---------|-------------|
| **Embedding** | Rappresentazione numerica (vettore) di un dato, dove la posizione nello spazio riflette il significato |
| **Vector** | Array di float a dimensione fissa (es. 1536 float) |
| **Dimensionalità** | Numero di float nel vettore (es. 384, 768, 1536, 3072) |
| **Token** | Unità di testo per il modello (~0.75 parole in media, varia per lingua) |
| **KNN** | K-Nearest Neighbors: trova i K vettori più vicini |
| **ANN** | Approximate Nearest Neighbor: versione approssimata (ma veloce) di KNN |
| **HNSW** | Hierarchical Navigable Small World: algoritmo di indicizzazione per ANN |
| **Cosine similarity** | Metrica che misura l'angolo tra due vettori (1 = identici, 0 = scorrelati) |
| **Collection** | Contenitore di vettori in un vector DB (equivalente di una tabella SQL) |
| **Point** | Un vettore + il suo payload in Qdrant (equivalente di una riga SQL) |
| **Payload** | Metadata JSON associati a un vettore |
| **Chunk** | Pezzo di un documento più grande, vettorializzato separatamente |
| **RAG** | Retrieval Augmented Generation: dare contesto da un vector DB a un LLM |
| **Reranking** | Secondo passaggio per riordinare i risultati con un modello più preciso |
| **Fine-tuning** | Addestrare un modello sui tuoi dati specifici (diverso da RAG) |
| **Quantization** | Comprimere vettori (es. float32 → int8) per risparmiare memoria |
| **mmap** | Memory-mapped file: il vector DB carica i dati dal disco come se fossero in RAM |

---

## 17. Risorse e prossimi passi

### Documentazione ufficiale
- Qdrant: https://qdrant.tech/documentation/
- OpenAI Embeddings: https://platform.openai.com/docs/guides/embeddings
- Sentence Transformers (modelli locali): https://www.sbert.net/
- Anthropic Claude API: https://docs.anthropic.com/

### Prossimi argomenti da esplorare
- **Reranking**: usare un modello cross-encoder per migliorare la qualità dei risultati
- **Hybrid search**: combinare ricerca vettoriale + keyword (BM25) per il meglio di entrambi
- **Multi-tenancy**: isolare i dati per cliente/utente in un singolo vector DB
- **Streaming ingestion**: pipeline real-time per aggiornare il vector DB quando i dati cambiano
- **Evaluation**: come misurare la qualità della ricerca semantica (precision, recall, nDCG)
- **Fine-tuning embedding**: addestrare un modello di embedding sul tuo dominio specifico
- **Multimodal embedding**: vettorializzare immagini e testo nello stesso spazio

---

> **Nota**: questo documento è un punto di partenza. Ogni sezione può essere approfondita
> in base alle esigenze specifiche del progetto. Il consiglio è partire dal Docker Compose
> con Qdrant, fare qualche test con dati reali, e poi decidere il percorso.
