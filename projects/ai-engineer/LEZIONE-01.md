# Lezione 01 — Ambiente + Primo Prompt LLM Funzionante

> **Modulo**: 0 — Setup Operativo
> **Il problema**: Devi poter chiamare un LLM da codice e ottenere un risultato. Oggi.
> **Cosa produci**: Ambiente Python pronto + script che chiama Claude e OpenAI e restituisce una risposta.

---

## Il pattern: LLM come servizio API

- **Cos'è**: Un LLM è un servizio che riceve testo (prompt) e restituisce testo (risposta). Lo chiami via HTTP come qualsiasi API REST, ma usi un SDK tipizzato.
- **Quando si usa**: Ogni volta che hai bisogno di comprensione del linguaggio naturale, generazione di testo, analisi di contenuto, trasformazione dati non strutturati.
- **Quando NON si usa**: Calcoli deterministi, query SQL, logica che puoi scrivere con if/else. Se puoi farlo senza LLM, fallo senza.
- **Nel tuo stack**: È come chiamare un servizio esterno via `HttpClient` in C#. Mandi una request, ricevi una response. La differenza è che il "server" capisce il linguaggio naturale.

Questo pattern lo riuserai in ogni singola lezione del corso e in ogni progetto AI che farai.

---

## Ponte dal tuo stack

| Tu già sai | Qui è uguale, solo che... |
|---|---|
| `dotnet new` + NuGet | `python -m venv` + pip — stessa idea, sintassi diversa |
| `appsettings.json` | `.env` + `python-dotenv` — più semplice |
| `HttpClient.PostAsync(url, json)` | `client.messages.create(...)` — SDK tipizzato, non HTTP grezzo |
| `$"Ciao {nome}"` | `f"Ciao {nome}"` — identico |

Non serve altro. Python lo impari usandolo, non studiandolo.

---

## 1. Setup ambiente

```bash
# Verifica Python (serve 3.11+)
python --version

# Crea cartella di lavoro e venv
mkdir C:/!claude/ai-lab
cd C:/!claude/ai-lab
python -m venv .venv
source .venv/Scripts/activate    # Git Bash / WSL
# .venv\Scripts\activate         # cmd
# .venv\Scripts\Activate.ps1     # PowerShell

# Installa le dipendenze che ci servono
pip install openai anthropic python-dotenv
```

## 2. API Key

Crea il file `.env` nella root di `ai-lab`:

```env
OPENAI_API_KEY=sk-...
ANTHROPIC_API_KEY=sk-ant-...
```

Se non hai ancora le chiavi:
- OpenAI: https://platform.openai.com/api-keys
- Anthropic: https://console.anthropic.com/settings/keys

## 3. Prima chiamata — Claude

Crea `01_primo_prompt.py`:

```python
import os
from dotenv import load_dotenv
from anthropic import Anthropic

load_dotenv()

client = Anthropic()  # legge ANTHROPIC_API_KEY da ambiente

# Chiamata base: mandi un messaggio, ricevi una risposta
response = client.messages.create(
    model="claude-sonnet-4-20250514",
    max_tokens=1024,
    messages=[
        {"role": "user", "content": "Sei un assistente tecnico. Spiegami in 3 righe cos'è un embedding."}
    ]
)

print(response.content[0].text)
print(f"\n--- Token usati: {response.usage.input_tokens} in, {response.usage.output_tokens} out ---")
```

```bash
python 01_primo_prompt.py
```

Se vedi una risposta e il conteggio token, il setup funziona.

**Cosa è successo**: hai mandato un messaggio HTTP all'API Anthropic con un prompt. L'SDK ha gestito auth, serializzazione, retry. Come chiamare una Web API qualsiasi, ma il server è un LLM.

## 4. Stessa cosa con OpenAI

Crea `01_openai.py`:

```python
import os
from dotenv import load_dotenv
from openai import OpenAI

load_dotenv()

client = OpenAI()  # legge OPENAI_API_KEY da ambiente

response = client.chat.completions.create(
    model="gpt-4o-mini",
    messages=[
        {"role": "user", "content": "Sei un assistente tecnico. Spiegami in 3 righe cos'è un embedding."}
    ]
)

print(response.choices[0].message.content)
print(f"\n--- Token usati: {response.usage.prompt_tokens} in, {response.usage.completion_tokens} out ---")
```

**Nota le differenze**:
- Claude: `response.content[0].text` — OpenAI: `response.choices[0].message.content`
- Claude: `usage.input_tokens` / `output_tokens` — OpenAI: `usage.prompt_tokens` / `completion_tokens`
- Il resto è quasi identico. Due SDK diversi, stesso concetto.

## 5. System prompt — Come dare istruzioni all'LLM

Il system prompt è come il "ruolo" dell'LLM. Nella pratica è dove definisci il comportamento del tuo assistente AI.

```python
from anthropic import Anthropic
from dotenv import load_dotenv

load_dotenv()
client = Anthropic()

# System prompt: definisce CHI è l'assistente
# Messages: la conversazione con l'utente
response = client.messages.create(
    model="claude-sonnet-4-20250514",
    max_tokens=1024,
    system="Sei un esperto di database SQL Server. Rispondi sempre in italiano. Sii conciso.",
    messages=[
        {"role": "user", "content": "Quando conviene usare un indice columnstore?"}
    ]
)

print(response.content[0].text)
```

Il system prompt è il primo pattern critico del prompt engineering. Tutto il resto (few-shot, chain-of-thought, ecc.) lo vediamo nella lezione 04. Per ora ti basta sapere: **system = istruzioni**, **messages = conversazione**.

## 6. Parametri che contano

```python
response = client.messages.create(
    model="claude-sonnet-4-20250514",  # quale modello
    max_tokens=2048,              # limite output (non input)
    temperature=0.0,              # 0 = deterministico, 1 = creativo
    system="...",
    messages=[...]
)
```

| Parametro | Cosa fa | Quando tocchi |
|---|---|---|
| `model` | Quale LLM usi | Sempre — è la scelta più importante (lezione 05) |
| `max_tokens` | Tetto output | Alzalo se le risposte vengono troncate |
| `temperature` | Casualità | 0 per estrazione dati/codice, 0.7+ per testo creativo |

Non servono altri parametri per iniziare. `top_p`, `top_k`, penalty vari — li tocchi solo se hai un problema specifico, e nella maggior parte dei casi non li tocchi mai.

---

## Esercizio

Crea `01_esercizio.py` che fa questo:

1. Prende in input il nome di un file `.cs` o `.sql` dal tuo disco (un file vero, di un tuo progetto)
2. Lo legge
3. Lo manda a Claude con il system prompt: `"Analizza questo codice e restituisci: 1) Cosa fa in 2 righe. 2) Eventuali problemi evidenti. 3) Un suggerimento di miglioramento. Rispondi in italiano."`
4. Stampa la risposta

Questo è un tool che potresti usare davvero. Non è un toy example.

```python
import sys
import os
from dotenv import load_dotenv
from anthropic import Anthropic

load_dotenv()
client = Anthropic()

# Prendi il path del file come argomento
if len(sys.argv) < 2:
    print("Uso: python 01_esercizio.py <path-file>")
    sys.exit(1)

file_path = sys.argv[1]

with open(file_path, "r", encoding="utf-8") as f:
    code = f.read()

# Determina il linguaggio dall'estensione
ext = os.path.splitext(file_path)[1]
lang = {"cs": "C#", ".sql": "T-SQL", ".ts": "TypeScript", ".tsx": "TypeScript/React"}.get(ext, "codice")

response = client.messages.create(
    model="claude-sonnet-4-20250514",
    max_tokens=2048,
    temperature=0.0,
    system=f"Sei un senior developer esperto di {lang}. Analizza il codice e restituisci: 1) Cosa fa in 2 righe. 2) Eventuali problemi evidenti. 3) Un suggerimento di miglioramento. Rispondi in italiano.",
    messages=[
        {"role": "user", "content": f"```{lang}\n{code}\n```"}
    ]
)

print(f"Analisi di: {file_path}\n")
print(response.content[0].text)
print(f"\n--- Token: {response.usage.input_tokens} in, {response.usage.output_tokens} out ---")
```

Provalo su un file reale:
```bash
python 01_esercizio.py "C:/percorso/al/tuo/file.cs"
```

---

## Esercizio alternativo: applicalo altrove

Ora che sai chiamare un LLM, prova un contesto completamente diverso. Crea `01_esercizio_alt.py`:

Prendi un file di testo qualsiasi (un'email, un documento, un log) e chiedi all'LLM di:
- Classificarlo (cos'è: email, log, contratto, fattura...)
- Estrarre le 3 informazioni più importanti
- Dare un livello di urgenza (alta/media/bassa)

```python
import sys
from dotenv import load_dotenv
from anthropic import Anthropic

load_dotenv()
client = Anthropic()

if len(sys.argv) < 2:
    print("Uso: python 01_esercizio_alt.py <path-file-testo>")
    sys.exit(1)

with open(sys.argv[1], "r", encoding="utf-8") as f:
    content = f.read()

response = client.messages.create(
    model="claude-sonnet-4-20250514",
    max_tokens=1024,
    temperature=0.0,
    system="Analizza il documento fornito. Restituisci: 1) Tipo di documento. 2) Le 3 informazioni più importanti. 3) Livello di urgenza (alta/media/bassa) con motivazione. Rispondi in italiano.",
    messages=[{"role": "user", "content": content}]
)

print(response.content[0].text)
```

Lo scopo è capire che il pattern è lo stesso indipendentemente dal dominio: mandi testo, ricevi analisi. Il codice cambia solo nel system prompt.

---

## Checkpoint

Hai completato questa lezione quando:

- [ ] `python 01_primo_prompt.py` funziona e stampa una risposta da Claude
- [ ] `python 01_openai.py` funziona e stampa una risposta da OpenAI
- [ ] Capisci la differenza tra system prompt e messages
- [ ] `python 01_esercizio.py` analizza un tuo file di codice reale
- [ ] `python 01_esercizio_alt.py` analizza un documento di tipo diverso
- [ ] Sai rispondere: "Se domani devo analizzare un tipo di file che non ho mai visto, da dove parto?" (risposta: stesso codice, cambio solo il system prompt)

---

## Prossima lezione

**Lezione 02**: Output strutturato con Pydantic — L'LLM ti restituisce JSON tipizzato e validato, non testo libero. È il pattern che trasforma l'LLM da "giocattolo" a "componente della tua pipeline". Lo userai pesantemente in P1 e P2 per il mapping automatico dei file.
