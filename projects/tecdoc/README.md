# Documentazione Progetto TecDoc

## Operazioni Standard
- **Splitta i ktype per PCD**: Questa operazione consiste nell'identificare i `ktype` associati a un `modelid` che presentano valori di `PCD` differenti nel file delle anomalie (es. `id029`).
    1. **Mantenimento ID Originale**: Il primo gruppo di `ktype` associato al primo valore di `PCD` riscontrato deve rimanere associato al `ModelId` originale.
    2. **Creazione Nuovi Modelli**: Per ogni valore di `PCD` differente dal primo, viene creato un nuovo record in `TecDocModels` (partendo da `3000000`), duplicando i dati del modello originale.
    3. **Aggiornamento Univoco Veicoli**: In `TecDocVehicles`, il `ModelId` (e `ModelId_Source`) deve essere aggiornato per i `ktype` corrispondenti ai nuovi PCD. **IMPORTANTE**: Non duplicare mai le righe dei veicoli; la chiave primaria `Ktype` deve rimanere univoca nel file di output.
    4. **File di Output**: I file `tecdocmodels-new.xlsx` e `tecdocvehicles-new.xlsx` conterranno solo i record dei modelli e dei veicoli coinvolti nell'operazione di split.

## File del Progetto

Questa directory contiene i file Excel relativi ai veicoli e ai modelli TecDoc.

### File Excel:
- `id020-TecDocVehicles-20260413-100047.xlsx`: Dati dei veicoli TecDoc.
- `id023-TecDocModels-20260413-095958.xlsx`: Dati dei modelli TecDoc.
- `id029-Veicoli-errati-PCD-20260413-100119.xlsx`: Dati dei veicoli con PCD errato.

## Note del Progetto
- 13/04/2026: Richiesta analisi modelid 4211 per split PCD.

