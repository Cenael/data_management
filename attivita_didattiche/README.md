# Sistema di Gestione Attività Didattiche

## Descrizione del Progetto

Questo database è progettato per gestire le attività didattiche di un istituto di formazione, tracciando studenti, corsi, docenti, tutor e tutte le attività formative.

## Modello Concettuale

### Entità Principali

1. **STUDENTE**
   - Gestisce l'anagrafica degli studenti iscritti
   - Attributi: Codice, Nome, Cognome, Data di nascita, Email, Telefono, Indirizzo

2. **CORSO**
   - Rappresenta i corsi offerti dall'istituto
   - Attributi: Codice, Nome, Descrizione, Date inizio/fine, Numero ore, Livello

3. **UNITA_FORMATIVA**
   - Moduli formativi che compongono ogni corso
   - Attributi: Codice, Titolo, Descrizione, Numero ore, Ordine sequenziale

4. **DOCENTE**
   - Anagrafica dei docenti che tengono le lezioni
   - Attributi: Codice, Nome, Cognome, Email, Telefono, Specializzazione, CV

5. **TUTOR**
   - Tutor che supportano gli studenti durante i corsi
   - Attributi: Codice, Nome, Cognome, Email, Telefono, Area di competenza

6. **SEDE**
   - Sedi fisiche o online dove si svolgono i corsi
   - Attributi: Codice, Nome, Indirizzo, Città, CAP, Capienza, Tipo (fisica/online)

7. **AULA**
   - Aule disponibili all'interno delle sedi
   - Attributi: Codice, Nome, Capienza, Attrezzature

### Entità Aggiuntive

8. **ISCRIZIONE**
   - Gestisce le iscrizioni degli studenti ai corsi
   - Relazione N:M tra Studente e Corso
   - Attributi: Data iscrizione, Stato (attivo/completato/ritirato), Valutazione finale

9. **LEZIONE**
   - Traccia le singole lezioni programmate
   - Collega Unità Formativa, Docente e Aula
   - Attributi: Data/Ora, Durata, Argomento

10. **TUTORAGGIO**
    - Assegnazione dei tutor agli studenti per specifici corsi
    - Relazione N:M tra Tutor, Studente e Corso
    - Attributi: Data inizio, Data fine, Note

11. **MATERIALE_DIDATTICO**
    - Materiali di supporto per le unità formative
    - Attributi: Titolo, Tipo (slide/video/documento), URL, Descrizione

12. **VALUTAZIONE_UF**
    - Valutazioni degli studenti per ogni unità formativa
    - Attributi: Voto, Superata (sì/no), Data valutazione

## Schema delle Relazioni

```
CORSO (1) ─────< (N) UNITA_FORMATIVA
  │
  │ (N)
  │
  ├─── ISCRIZIONE ───< (N) STUDENTE
  │
  └─── TUTORAGGIO ──┬─< (N) TUTOR
                    └─< (N) STUDENTE

UNITA_FORMATIVA (1) ─────< (N) LEZIONE ───> (1) DOCENTE
                      │                  └───> (1) AULA
                      │
                      └─────< (N) MATERIALE_DIDATTICO
                      │
                      └─────< (N) VALUTAZIONE_UF ───> (1) STUDENTE

SEDE (1) ─────< (N) AULA
```

## Cardinalità delle Relazioni

1. **Corso - Unità Formativa**: 1:N
   - Un corso ha più unità formative
   - Un'unità formativa appartiene a un solo corso

2. **Studente - Corso** (tramite Iscrizione): N:M
   - Uno studente può iscriversi a più corsi
   - Un corso ha più studenti iscritti

3. **Docente - Unità Formativa** (tramite Lezione): N:M
   - Un docente può insegnare in più unità formative
   - Un'unità formativa può essere insegnata da più docenti

4. **Tutor - Studente - Corso** (tramite Tutoraggio): N:M ternaria
   - Un tutor può seguire più studenti in più corsi
   - Uno studente può avere più tutor

5. **Sede - Aula**: 1:N
   - Una sede contiene più aule
   - Un'aula appartiene a una sola sede

6. **Aula - Lezione**: 1:N
   - Un'aula ospita più lezioni
   - Una lezione si svolge in un'aula (o online)

7. **Studente - Unità Formativa** (tramite ValutazioneUF): N:M
   - Uno studente riceve valutazioni per più unità formative
   - Un'unità formativa ha valutazioni di più studenti

## Vincoli di Integrità

### Vincoli di Chiave Primaria
- Ogni entità ha una chiave primaria auto-incrementale

### Vincoli di Chiave Esterna
- Tutti i riferimenti tra tabelle sono gestiti con ON DELETE CASCADE/RESTRICT
- Le lezioni non possono essere eliminate se cancelli un docente (RESTRICT)
- Se elimini un corso, vengono eliminate tutte le unità formative, iscrizioni, ecc. (CASCADE)

### Vincoli di Dominio
- `Livello` del corso: Base, Intermedio, Avanzato
- `Stato` iscrizione: Attivo, Completato, Ritirato
- `TipoSede`: Fisica, Online
- `TipoMateriale`: Slide, Video, Documento, Esercizi, Altro
- Valutazioni: tra 0 e 100

### Vincoli di Tupla
- `DataFine` del corso >= `DataInizio`
- `DataFine` del tutoraggio >= `DataInizio` (se presente)
- Voto nelle valutazioni: 0 <= Voto <= 100

### Vincoli di Unicità
- Email univoche per Studenti, Docenti e Tutor
- Nome sede + indirizzo univoci
- Nome aula + sede univoci
- Studente + corso univoci nelle iscrizioni
- Ordine + corso univoci nelle unità formative

## Viste Disponibili

1. **v_Iscrizioni_Attive**: Elenco iscrizioni attive con dettagli studente e corso
2. **v_Calendario_Lezioni**: Calendario completo delle lezioni con tutti i dettagli
3. **v_Studenti_Tutor**: Associazioni studente-tutor con stato del tutoraggio
4. **v_Progressione_Studenti**: Progressione e performance degli studenti nei corsi

## Query Utili

Il file SQL include query commentate per:
- Elenco studenti per corso
- Carico di lavoro dei docenti
- Utilizzo delle aule
- Performance degli studenti con media voti
- Progressione studenti nei corsi

## File del Progetto

- **attivita_didattiche.sql**: Schema completo del database con dati di esempio
- **attivita_didattiche.py**: Script Python per esportare i dati in CSV
- **conc_model.drawio**: Diagramma ER del modello concettuale (da aprire con draw.io)
- **README.md**: Questa documentazione

## Come Utilizzare

### 1. Creare il Database

```sql
mysql -u root -p < attivita_didattiche.sql
```

### 2. Esportare i Dati in CSV

```bash
python attivita_didattiche.py
```

Assicurati di configurare le credenziali del database nello script Python.

### 3. Visualizzare il Diagramma

Apri il file `conc_model.drawio` con:
- draw.io web: https://app.diagrams.net/
- VS Code extension: Draw.io Integration
- Desktop app: https://www.diagrams.net/

## Funzionalità Non Implementate

Come da requisiti, il sistema **NON** gestisce:
- ❌ Calendario assenze e presenze
- ❌ Contabilità e pagamenti
- ❌ Forniture e fornitori

## Possibili Estensioni Future

1. **Valutazioni**: Aggiungere tipologie di valutazione (scritto, orale, pratico)
2. **Certificazioni**: Tracciare le certificazioni rilasciate agli studenti
3. **Prerequisiti**: Gestire prerequisiti tra corsi o unità formative
4. **Feedback**: Sistema di feedback studenti sui corsi e docenti
5. **Risorse**: Gestione risorse condivise (proiettori, computer, ecc.)

## Autore

Sistema progettato per la gestione completa delle attività didattiche di un istituto di formazione.

Data creazione: Ottobre 2025
