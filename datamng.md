**Diagramma E/R (entità - relazioni) -> mappa del database**

Cardinalità delle relazioni => (crow's feet notation)
Livello 0: 
Si parte dal _conceptual model_, si aggiungono gli attribut per arrivare al design delle tabelle 
I diagrammi ER si usano in fase di progettazione => scomporre il problema in passi più piccoli, aiuta a visualizzare le relazioni
Le foreign Key sono sempre primary key di un'altra tabella 

Alle entità si associano tutti gli attributi (per ogni entità) in una prima fase, poi si iniziano a dividere in base alle condizioni delle forme standard (design) del database.

Prodotto cartesiano: ???

Dipendenza dalla Primary Key: La primary key identifica le istanze presenti in tabella. questa si chiamata tale se la colonna descrive un aspetto specifico legato all'entità della Primary Key 

Normalizzazione database: 
1. **Prima forma normale: Le informazioni sono memorizzate in una tabella relazionale e ogni colonna contiene valori atomici, e non ci sono gruppi di colonne ripetuti** (relazionale: ogni singolo record ha una primary key int autoincrementale)

2. **Seconda forma normale: La tabella è in prima forma normale + tutte le colonne dipendono dalla chiave primaria della tabella (no dipendenza parziale)** -> Non ci devono essere informazioni relative ad altre primary keys (_es. tabella sull'employee tutte le colonne devono dipendere da lui, non vanno aggiunte info sull'ufficio dei clienti_)
Se la primary key è composta, la dipendenza deve essere per entrambe le primary key
Si rimuovono quindi eventuali dipendenze parziali 

3. **Terza forma normale: tabella in seconda forma normale + tutte le sue colonne non devono dipendere transitivamente dalla primary key**


