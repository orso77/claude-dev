# Confronto `WheelsNet.dbo.HomologationSpares` (prod 192.168.100.52) vs `WheelSystems.dbo.AcSpareWheels` (old 77.81.228.147)

Verifica: le due tabelle hanno gli stessi record? **NO — non identiche**, ma quasi allineate (~90,7%).

## Struttura / granularità (diverse)

| | OLD AcSpareWheels | NEW HomologationSpares |
|---|---|---|
| Chiave veicolo | `Ktype` (int) | `VehicleModelId` (int) |
| Brand | `ManufacturerId` (int, = `Brands.OldId`) | `SpareBrandId` (varchar, = `Brands.Id` es. `356S`) |
| Codice | `ManufacturerCod` nchar(100) | `SpareManufacturerCode` varchar(50) |
| Note | `Notes` | `Notes` (+ `Timestamp`) |
| Righe | **202.284** (livello ktype) | **13.754** (livello modello) |

La OLD è a livello **Ktype** (molti ktype per modello); la NEW è a livello **VehicleModelId**. Non confrontabili 1:1 per riga.

Mapping usato: brand `Brands.OldId = AcSpareWheels.ManufacturerId` e `Brands.Id = HomologationSpares.SpareBrandId`
(`356S↔349`, `NUV↔348`, `BS↔380`, `TAZ↔547`); veicolo `AcSpareWheels.Ktype → TecDocVehicles.ModelId = HomologationSpares.VehicleModelId`.

## Riconciliazione a livello `(ModelId, Brand, ManufacturerCod)`

| Metrica | Valore |
|---|--:|
| OLD ktype distinct | 15.336 (solo **2** non mappate su TecDocVehicles) |
| OLD_set (ModelId,Brand,Cod) | 15.126 |
| NEW_set (ModelId,Brand,Cod) | 13.754 |
| **In entrambi** | **13.718** (90,7% dell'OLD) |
| **Solo OLD (mancano nel NEW)** | **1.408** |
| **Solo NEW (in più)** | **36** |

Solo-OLD per brand: 356S=494, NUV=494, BS=420. Solo-NEW: 356S=16, NUV=13, BS=7.

## Natura del gap (1.408 mancanti)

- **1.379 / 1.408**: il **codice ricambio esiste comunque nel NEW** (stesso brand, su altri modelli) → non è che manchino i prodotti, mancano **associazioni ricambio↔modello-veicolo** specifiche.
- **1.351 / 1.408**: il `ModelId` **non è presente affatto** nel NEW → sono omologazioni per **modelli veicolo usciti dal catalogo attivo** (rigenerazione TecDoc), coerente con le differenze già viste sulle fitment ktype.
- Solo **57** hanno il modello presente nel NEW ma con codice diverso.

## Conclusione

`HomologationSpares` **non ha esattamente gli stessi record**: copre **13.718 delle 15.126** omologazioni (modello,brand,codice) desumibili dal vecchio `AcSpareWheels` (90,7%), con **1.408 in meno** e **36 in più**. Il gap NON è perdita di prodotti (i codici ci sono quasi tutti), ma **~1.400 associazioni ricambio↔modello** presenti nel vecchio e assenti nel nuovo — per lo più su modelli veicolo non più nel catalogo attivo. Da valutare se questi modelli vadano reintegrati o se l'uscita dal catalogo è voluta.

Nota metodologica: il mapping Ktype→ModelId usa il `TecDocVehicles` **attuale**; una piccola quota del gap può derivare dal drift del catalogo ktype nel tempo, non da vera perdita dati (comunque solo 2 ktype risultano non mappate).
