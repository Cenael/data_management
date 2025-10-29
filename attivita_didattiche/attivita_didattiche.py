"""
Sistema di Gestione Attività Didattiche
Modulo per l'export del database in formato CSV
"""

import mysql.connector
from datetime import datetime
import os
import csv

# Configurazione database
DB_CONFIG = {
    'host': 'localhost',
    'user': 'root',
    'password': '',  # Inserisci la tua password
    'database': 'AttivitaDidatticheDB'
}

# Directory di output
OUTPUT_DIR = f'csv_out/AttivitaDidatticheDB_{datetime.now().strftime("%Y%m%d_%H%M%S")}'

def create_connection():
    """Crea connessione al database"""
    try:
        conn = mysql.connector.connect(**DB_CONFIG)
        print(f"✓ Connessione al database {DB_CONFIG['database']} riuscita")
        return conn
    except mysql.connector.Error as err:
        print(f"✗ Errore di connessione: {err}")
        return None

def get_tables(cursor):
    """Ottiene la lista delle tabelle del database"""
    cursor.execute("SHOW TABLES")
    tables = [table[0] for table in cursor.fetchall()]
    # Escludiamo le viste (iniziano con v_)
    tables = [t for t in tables if not t.startswith('v_')]
    return tables

def export_table_to_csv(cursor, table_name, output_dir):
    """Esporta una tabella in formato CSV"""
    try:
        # Ottieni i dati dalla tabella
        cursor.execute(f"SELECT * FROM {table_name}")
        rows = cursor.fetchall()
        
        if not rows:
            print(f"  ⚠ Tabella {table_name} vuota")
            return 0
        
        # Ottieni i nomi delle colonne
        column_names = [desc[0] for desc in cursor.description]
        
        # Crea il file CSV
        csv_file = os.path.join(output_dir, f"{table_name}.csv")
        with open(csv_file, 'w', newline='', encoding='utf-8') as f:
            writer = csv.writer(f)
            writer.writerow(column_names)
            writer.writerows(rows)
        
        print(f"  ✓ Esportata tabella {table_name}: {len(rows)} righe")
        return len(rows)
    
    except Exception as e:
        print(f"  ✗ Errore nell'esportazione di {table_name}: {e}")
        return 0

def create_import_order_file(output_dir, tables):
    """Crea un file con l'ordine di importazione delle tabelle"""
    # Ordine corretto per rispettare i vincoli di chiave esterna
    import_order = [
        'Sede',
        'Aula',
        'Studente',
        'Docente',
        'Tutor',
        'Corso',
        'UnitaFormativa',
        'Iscrizione',
        'Lezione',
        'Tutoraggio',
        'MaterialeDidattico',
        'ValutazioneUF'
    ]
    
    # Filtra solo le tabelle che esistono
    import_order = [t for t in import_order if t in tables]
    
    order_file = os.path.join(output_dir, '_IMPORT_ORDER.txt')
    with open(order_file, 'w', encoding='utf-8') as f:
        f.write("ORDINE DI IMPORTAZIONE DELLE TABELLE\n")
        f.write("=" * 50 + "\n\n")
        f.write("Importare le tabelle nel seguente ordine per rispettare\n")
        f.write("i vincoli di chiave esterna:\n\n")
        for i, table in enumerate(import_order, 1):
            f.write(f"{i}. {table}.csv\n")
    
    print(f"✓ Creato file _IMPORT_ORDER.txt")

def generate_readme(output_dir):
    """Genera un file README con informazioni sul database"""
    readme_file = os.path.join(output_dir, 'README.md')
    with open(readme_file, 'w', encoding='utf-8') as f:
        f.write("# Database Attività Didattiche - Export CSV\n\n")
        f.write(f"**Data export:** {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n\n")
        f.write("## Descrizione\n\n")
        f.write("Questo database gestisce le attività didattiche di un istituto di formazione.\n\n")
        f.write("## Entità principali\n\n")
        f.write("- **Studente**: Anagrafica degli studenti iscritti\n")
        f.write("- **Corso**: Corsi offerti dall'istituto\n")
        f.write("- **UnitaFormativa**: Moduli formativi che compongono i corsi\n")
        f.write("- **Docente**: Anagrafica dei docenti\n")
        f.write("- **Tutor**: Anagrafica dei tutor di supporto\n")
        f.write("- **Sede**: Sedi fisiche e online dell'istituto\n")
        f.write("- **Aula**: Aule disponibili nelle varie sedi\n")
        f.write("- **Iscrizione**: Iscrizioni studenti ai corsi\n")
        f.write("- **Lezione**: Lezioni programmate\n")
        f.write("- **Tutoraggio**: Assegnazione tutor agli studenti\n")
        f.write("- **MaterialeDidattico**: Materiali di supporto alle unità formative\n")
        f.write("- **ValutazioneUF**: Valutazioni degli studenti nelle unità formative\n\n")
        f.write("## Importazione\n\n")
        f.write("Per importare i dati, seguire l'ordine specificato nel file `_IMPORT_ORDER.txt`\n")
        f.write("per rispettare i vincoli di chiave esterna.\n")
    
    print(f"✓ Creato file README.md")

def print_statistics(cursor):
    """Stampa statistiche sul database"""
    print("\n" + "=" * 60)
    print("STATISTICHE DATABASE")
    print("=" * 60)
    
    stats_queries = {
        'Numero Studenti': 'SELECT COUNT(*) FROM Studente',
        'Numero Docenti': 'SELECT COUNT(*) FROM Docente',
        'Numero Tutor': 'SELECT COUNT(*) FROM Tutor',
        'Numero Corsi': 'SELECT COUNT(*) FROM Corso',
        'Numero Unità Formative': 'SELECT COUNT(*) FROM UnitaFormativa',
        'Iscrizioni Attive': "SELECT COUNT(*) FROM Iscrizione WHERE Stato = 'Attivo'",
        'Numero Lezioni': 'SELECT COUNT(*) FROM Lezione',
        'Numero Sedi': 'SELECT COUNT(*) FROM Sede',
        'Numero Aule': 'SELECT COUNT(*) FROM Aula'
    }
    
    for label, query in stats_queries.items():
        try:
            cursor.execute(query)
            result = cursor.fetchone()[0]
            print(f"{label:.<40} {result:>5}")
        except:
            print(f"{label:.<40} {'N/A':>5}")
    
    print("=" * 60 + "\n")

def main():
    """Funzione principale"""
    print("\n" + "=" * 60)
    print("EXPORT DATABASE ATTIVITÀ DIDATTICHE")
    print("=" * 60 + "\n")
    
    # Connessione al database
    conn = create_connection()
    if not conn:
        return
    
    cursor = conn.cursor()
    
    # Stampa statistiche
    print_statistics(cursor)
    
    # Crea directory di output
    os.makedirs(OUTPUT_DIR, exist_ok=True)
    print(f"✓ Directory di output: {OUTPUT_DIR}\n")
    
    # Ottieni lista tabelle
    tables = get_tables(cursor)
    print(f"Trovate {len(tables)} tabelle da esportare\n")
    
    # Esporta ogni tabella
    total_rows = 0
    for table in tables:
        rows = export_table_to_csv(cursor, table, OUTPUT_DIR)
        total_rows += rows
    
    # Crea file supplementari
    print()
    create_import_order_file(OUTPUT_DIR, tables)
    generate_readme(OUTPUT_DIR)
    
    # Chiudi connessione
    cursor.close()
    conn.close()
    
    print("\n" + "=" * 60)
    print(f"✓ Export completato!")
    print(f"  Tabelle esportate: {len(tables)}")
    print(f"  Righe totali: {total_rows}")
    print(f"  Directory: {OUTPUT_DIR}")
    print("=" * 60 + "\n")

if __name__ == "__main__":
    main()
